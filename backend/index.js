require("dotenv").config();

const express = require("express");
const multer = require("multer");
const speech = require("@google-cloud/speech");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const {
  GoogleAIFileManager,
  FileState,
} = require("@google/generative-ai/server");
const fs = require("fs");

const queue = [];
let isProcessing = false;

// Creates clients for Google Cloud services
const client = new speech.SpeechClient();
const fileManager = new GoogleAIFileManager(process.env.API_KEY);
const genAI = new GoogleGenerativeAI(process.env.API_KEY);

const app = express();
const upload = multer({ dest: "uploads/" });

// Endpoint for Google Cloud Speech-to-Text (existing functionality)
app.post("/transcribe", upload.single("audio"), async (req, res) => {
  try {
    const filename = req.file.path;
    const encoding = "LINEAR16";
    const sampleRateHertz = 16000;
    const languageCode = "en-US";

    const audio = {
      content: fs.readFileSync(filename).toString("base64"),
    };

    const config = {
      encoding: encoding,
      sampleRateHertz: sampleRateHertz,
      languageCode: languageCode,
    };

    const request = {
      config: config,
      audio: audio,
    };

    const [response] = await client.recognize(request);
    const transcription = response.results
      .map((result) => result.alternatives[0].transcript)
      .join("\n");

    fs.unlinkSync(filename);
    res.json({ transcription: transcription });
  } catch (error) {
    console.error("Error during transcription:", error);
    res.status(500).send("Error transcribing audio");
  }
});

// New endpoint for Gemini AI transcription
app.post("/gemini-transcribe", upload.single("audio"), (req, res) => {
  queue.push({ req, res });
  processQueue();
});

async function processQueue() {
  if (isProcessing || queue.length === 0) {
    return;
  }

  isProcessing = true;
  const { req, res } = queue.shift();

  try {
    const filename = req.file.path;

    // Upload file to Gemini AI
    const uploadResult = await fileManager.uploadFile(filename, {
      mimeType: "audio/mp3",
      displayName: "Audio sample",
    });

    let file = await fileManager.getFile(uploadResult.file.name);
    while (file.state === FileState.PROCESSING) {
      await new Promise((resolve) => setTimeout(resolve, 10_000));
      file = await fileManager.getFile(uploadResult.file.name);
    }

    if (file.state === FileState.FAILED) {
      throw new Error("Audio processing failed.");
    }

    // Generate content with Gemini AI
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const result = await model.generateContent([
      "Provide a transcription of the audio.",
      {
        fileData: {
          fileUri: uploadResult.file.uri,
          mimeType: uploadResult.file.mimeType,
        },
      },
    ]);

    fs.unlinkSync(filename);
    res.json({ transcription: result.response.text() });
  } catch (error) {
    console.error("Error during Gemini AI transcription:", error);

    if (error.message.includes("fetch failed")) {
      res
        .status(503)
        .send("Service Unavailable: Failed to connect to Gemini AI API");
    } else {
      res.status(500).send("Error during Gemini AI transcription");
    }
  } finally {
    isProcessing = false;
    processQueue();
  }
}

// app.post("/gemini-transcribe", upload.single("audio"), async (req, res) => {
//   try {
//     const filename = req.file.path;

//     // Upload file to Gemini AI
//     const uploadResult = await fileManager.uploadFile(filename, {
//       mimeType: "audio/mp3",
//       displayName: "Audio sample",
//     });

//     let file = await fileManager.getFile(uploadResult.file.name);
//     while (file.state === FileState.PROCESSING) {
//       await new Promise((resolve) => setTimeout(resolve, 10_000));
//       file = await fileManager.getFile(uploadResult.file.name);
//     }

//     if (file.state === FileState.FAILED) {
//       throw new Error("Audio processing failed.");
//     }

//     // Generate content with Gemini AI
//     const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
//     const result = await model.generateContent([
//       "Provide a transcription of the audio.",
//       {
//         fileData: {
//           fileUri: uploadResult.file.uri,
//           mimeType: uploadResult.file.mimeType,
//         },
//       },
//     ]);

//     fs.unlinkSync(filename);
//     res.json({ transcription: result.response.text() });
//   } catch (error) {
//     console.error("Error during Gemini AI transcription:", error);
//     res.status(500).send("Error during Gemini AI transcription");
//   }
// });

app.listen(3000, () => {
  console.log("Server started on port 3000");
});
