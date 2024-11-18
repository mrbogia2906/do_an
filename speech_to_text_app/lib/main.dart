// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_speech/config/longrunning_result.dart';
// import 'package:google_speech/generated/google/cloud/speech/v2/cloud_speech.pb.dart';
// import 'package:google_speech/generated/google/longrunning/operations.pb.dart';
// import 'package:google_speech/generated/google/longrunning/operations.pbgrpc.dart';
// import 'package:google_speech/google_speech.dart';
// import 'package:path_provider/path_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio File Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const AudioRecognize(),
//     );
//   }
// }

// class AudioRecognize extends StatefulWidget {
//   const AudioRecognize({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _AudioRecognizeState();
// }

// class _AudioRecognizeState extends State<AudioRecognize> {
//   bool recognizing = false;
//   bool recognizeFinished = false;
//   String text = '';

//   void recognize() async {
//     setState(() {
//       recognizing = true;
//     });
//     final serviceAccount = ServiceAccount.fromString(
//         (await rootBundle.loadString(
//             'assets/google/gen-lang-client-0446786270-0de2af86d9e3.json')));
//     final speechToText = SpeechToTextV2.viaServiceAccount(serviceAccount,
//         projectId: 'gen-lang-client-0446786270');
//     final config = _getConfig();
//     final audio = await _getAudioContent('test.wav');

//     await speechToText.recognize(config, audio).then((value) {
//       setState(() {
//         text = value.results
//             .map((e) => e.alternatives.first.transcript)
//             .join('\n');
//       });
//     }).whenComplete(() => setState(() {
//           recognizeFinished = true;
//           recognizing = false;
//         }));
//   }

//   void streamingRecognize() async {
//     setState(() {
//       recognizing = true;
//     });
//     final serviceAccount = ServiceAccount.fromString(
//         (await rootBundle.loadString(
//             'assets/google/gen-lang-client-0446786270-0de2af86d9e3.json')));
//     final speechToText = SpeechToTextV2.viaServiceAccount(serviceAccount,
//         projectId: 'gen-lang-client-0446786270');
//     final config = _getConfig();

//     final responseStream = speechToText.streamingRecognize(
//         StreamingRecognitionConfigV2(
//             config: config,
//             streamingFeatures:
//                 StreamingRecognitionFeatures(interimResults: true)),
//         await _getAudioStream('test.wav'));

//     responseStream.listen((data) {
//       setState(() {
//         text =
//             data.results.map((e) => e.alternatives.first.transcript).join('\n');
//         recognizeFinished = true;
//       });
//     }, onDone: () {
//       setState(() {
//         recognizing = false;
//       });
//     });
//   }

//   void longRunningRecognize() async {
//     setState(() {
//       recognizing = true;
//     });
//     final serviceAccount = ServiceAccount.fromString(
//         (await rootBundle.loadString(
//             'assets/google/gen-lang-client-0446786270-0de2af86d9e3.json')));
//     final speechToText = SpeechToTextV2.viaServiceAccount(serviceAccount,
//         projectId: 'gen-lang-client-0446786270');
//     final config = _getConfig();

//     try {
//       final result = await speechToText.pollingLongRunningRecognize(
//           config, 'gs://speech_to_text_k02/audio-files/test3.mp3');
//       setState(() {
//         text = result.results
//                 ?.map((e) => e.alternatives.first.transcript)
//                 .join('\n') ??
//             "";
//         recognizeFinished = true;
//         recognizing = false;
//       });
//     } catch (e) {
//       print('Error in longRunningRecognize: $e');
//       setState(() {
//         text = "Error occurred: $e";
//         recognizing = false;
//       });
//     }
//   }

//   RecognitionConfigV2 _getConfig() => RecognitionConfigV2(
//         features: RecognitionFeatures(enableAutomaticPunctuation: true),
//         autoDecodingConfig: AutoDetectDecodingConfig(),
//         model: RecognitionModelV2.long,
//         languageCodes: ['en-US'],
//       );

//   Future<void> _copyFileFromAssets(String name) async {
//     var data = await rootBundle.load('assets/audio/$name');
//     final directory = await getApplicationDocumentsDirectory();
//     final path = directory.path + '/$name';
//     await File(path).writeAsBytes(
//         data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//   }

//   Future<List<int>> _getAudioContent(String name) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = directory.path + '/$name';
//     if (!File(path).existsSync()) {
//       await _copyFileFromAssets(name);
//     }
//     return File(path).readAsBytesSync().toList();
//   }

//   Future<Stream<List<int>>> _getAudioStream(String name) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = directory.path + '/$name';
//     if (!File(path).existsSync()) {
//       await _copyFileFromAssets(name);
//     }

//     final content = File(path).readAsBytesSync();

//     // Set chunkLength to 25600 bytes
//     const chunkLength = 25600;
//     final stream = <List<int>>[];

//     for (var start = 0; start < content.length; start += chunkLength) {
//       final end = (start + chunkLength < content.length)
//           ? start + chunkLength
//           : content.length;
//       stream.add(content.sublist(start, end));
//     }

//     return Stream.fromIterable(stream);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Audio File Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: <Widget>[
//             if (recognizeFinished)
//               Expanded(
//                 child: _RecognizeContent(
//                   text: text,
//                 ),
//               ),
//             ElevatedButton(
//               onPressed: recognizing ? () {} : recognize,
//               child: recognizing
//                   ? const CircularProgressIndicator()
//                   : const Text('Test with recognize'),
//             ),
//             const SizedBox(
//               height: 10.0,
//             ),
//             ElevatedButton(
//               onPressed: recognizing ? () {} : streamingRecognize,
//               child: recognizing
//                   ? const CircularProgressIndicator()
//                   : const Text('Test with streaming recognize'),
//             ),
//             const SizedBox(
//               height: 10.0,
//             ),
//             ElevatedButton(
//               onPressed: recognizing ? () {} : longRunningRecognize,
//               child: recognizing
//                   ? const CircularProgressIndicator()
//                   : const Text('Test with longrunning recognize'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _RecognizeContent extends StatelessWidget {
//   final String? text;

//   const _RecognizeContent({Key? key, this.text}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: <Widget>[
//           const Text(
//             'The text recognized by the Google Speech Api:',
//           ),
//           const SizedBox(
//             height: 16.0,
//           ),
//           Flexible(
//             child: SingleChildScrollView(
//               child: Text(
//                 text ?? '---',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/data/providers/app_router_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/view_model/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo ProviderContainer
  final container = ProviderContainer();
  // Khởi tạo SharedPreferences và lấy dữ liệu người dùng
  await container.read(authViewModelProvider.notifier).initSharedPreferences();
  await container.read(authViewModelProvider.notifier).getData();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  ConsumerState createState() => _AppState();
}

class _AppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? Container(),
        );
      },
      debugShowCheckedModeBanner: true,
      routerConfig: ref.read(appRouterProvider).config(),
    );
  }
}
