import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';

class SignalRPage extends StatefulWidget {
  @override
  _SignalRPageState createState() => _SignalRPageState();
}

class _SignalRPageState extends State<SignalRPage> {
  final serverUrl = "https://core148.we-builds.com/payment-api/payment";
  HubConnection hubConnection;

  int _count = 0;
  bool _isSuccess = false;

  @override
  void initState() {
    // _callRead();
    super.initState();
    initSignalR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isSuccess
            ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      size: 108,
                      color: Colors.greenAccent,
                    ),
                    Text(
                      'ชำระเงินเสร็จสิ้น',
                      style: TextStyle(fontSize: 48),
                    )
                  ],
                ),
              )
            : Image.asset('assets/qr-code.png'),
      ),
    );
  }

  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();
    hubConnection.onclose((error) => print('Connection close'));
    hubConnection.on("paymentdata", _handleNewData);

    hubConnection.state == HubConnectionState.Disconnected
        ? hubConnection.start()
        : hubConnection.stop();

    // if (hubConnection.state == HubConnectionState.Disconnected)
    //   hubConnection.start();
    // else if (hubConnection.state == HubConnectionState.Connected)
    //   hubConnection.stop();

    // postDio(
    //   gApiQueueCreate,
    //   _model,
    //   isNoFuture: true,
    // );
  }

  _handleNewData(dynamic model) {
    // setState(() {

    // });

    // setState(() {
    //   // _model = model;
    // });

    print(model[0]['objectData'].length);

    if (_count == 0) {
      setState(() {
        _count = model[0]['objectData'].length;
      });
    } else {
      if (_count != model[0]['objectData'].length) {
        setState(() {
          _isSuccess = true;
        });
      }
    }
  }
}
