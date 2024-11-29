class CreateOrderResponse {
  final String zptranstoken;
  final String orderurl;
  final int returncode;
  final String returnmessage;
  final int subreturncode;
  final String subreturnmessage;
  final String ordertoken;

  CreateOrderResponse(
      {required this.zptranstoken,
      required this.orderurl,
      required this.returncode,
      required this.returnmessage,
      required this.subreturncode,
      required this.subreturnmessage,
      required this.ordertoken});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      zptranstoken: json['zp_trans_token'] as String,
      orderurl: json['order_url'] as String,
      returncode: json['return_code'] as int,
      returnmessage: json['return_message'] as String,
      subreturncode: json['sub_return_code'] as int,
      subreturnmessage: json['sub_return_message'] as String,
      ordertoken: json["order_token"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zp_trans_token': zptranstoken,
      'order_url': orderurl,
      'return_code': returncode,
      'return_message': returnmessage,
      'sub_return_code': subreturncode,
      'sub_return_message': subreturnmessage,
      'order_token': ordertoken,
    };
  }
}
