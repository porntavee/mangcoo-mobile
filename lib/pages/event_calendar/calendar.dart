import 'dart:convert';
import 'package:wereward/component/loading_image_network.dart';
import 'package:wereward/pages/event_calendar/event_calendar_form.dart';
import 'package:wereward/shared/api_provider.dart';
import 'package:wereward/shared/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import '../blank_page/dialog_fail.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  final storage = new FlutterSecureStorage();

  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  // CalendarController _calendarController;
  List objectData = [];
  Future<dynamic> futureModel;

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    futureModel = getMarkerEvent(now.year);

    // _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  Future<dynamic> getMarkerEvent(int year) async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var data = json.decode(value);
    final result = await postObjectData("m/EventCalendar/mark/read2", {
      "year": year,
      "organization":
          data['countUnit'] != '' ? json.decode(data['countUnit']) : [],
    });
    if (result['status'] == 'S') {
      setState(() {
        objectData = result['objectData'];
      });

      final _selectedDay = DateTime.now();
      _events = {};

      var now = DateTime.now();
      DateTime dateTimeNow = new DateTime(now.year, now.month, now.day);

      for (int i = 0; i < objectData.length; i++) {
        if (objectData[i]['items'].length > 0) {
          DateTime dateTimeCreatedAt = DateTime.parse(objectData[i]['date']);

          final differenceInDays =
              dateTimeNow.difference(dateTimeCreatedAt).inDays;

          if (differenceInDays == 0) {
            _events[_selectedDay] = objectData[i]['items'];
          } else if (differenceInDays < 0) {
            _events[_selectedDay.add(Duration(days: differenceInDays.abs()))] =
                objectData[i]['items'];
          } else if (differenceInDays > 0) {
            _events[_selectedDay.subtract(Duration(days: differenceInDays))] =
                objectData[i]['items'];
          }
        }
      }

      _selectedEvents = _events[_selectedDay] ?? [];
      // _calendarController = CalendarController();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              color: Colors.white,
              child: dialogFail(context),
            ),
          );
        } else if (objectData.length > 0) {
          return Container(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 8.0),
                  Expanded(child: _buildEventList()),
                ],
              ),
            ),
          );
        } else {
          return Container(
            child: Scaffold(
              body: Container(
                child: _buildTableCalendar(),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildTableCalendar() {
    return Container();

    // fixflutter2 TableCalendar(
    //   locale: 'th_th',
    //   calendarController: _calendarController,
    //   initialCalendarFormat: CalendarFormat.month,
    //   formatAnimation: FormatAnimation.slide,
    //   startingDayOfWeek: StartingDayOfWeek.sunday,
    //   availableGestures: AvailableGestures.all,
    //   availableCalendarFormats: const {
    //     CalendarFormat.month: '',
    //     CalendarFormat.week: '',
    //   },
    //   calendarStyle: CalendarStyle(
    //     outsideDaysVisible: true,
    //     weekendStyle: TextStyle().copyWith(
    //       color: Color(0xFFdec6c6),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //     holidayStyle: TextStyle().copyWith(
    //       color: Color(0xFFC5DAFC),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //   ),
    //   daysOfWeekStyle: DaysOfWeekStyle(
    //     weekendStyle: TextStyle().copyWith(
    //       color: Color(0xFFdec6c6),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //     weekdayStyle: TextStyle().copyWith(
    //       color: Color(0xFFC5DAFC),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //   ),
    //   headerStyle: HeaderStyle(
    //     centerHeaderTitle: true,
    //     formatButtonVisible: false,
    //     titleTextStyle: TextStyle().copyWith(
    //       color: Color(0xFFa7141c),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //       fontSize: 18.0,
    //     ),
    //   ),
    //   builders: CalendarBuilders(
    //     selectedDayBuilder: (context, date, _) {
    //       return FadeTransition(
    //         opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
    //         child: Container(
    //           margin: const EdgeInsets.all(5.0),
    //           padding: const EdgeInsets.only(top: 5.0, left: 5.0),
    //           color: Color(0xFFC5DAFC),
    //           width: 100,
    //           height: 100,
    //           child: Text(
    //             '${date.day}',
    //             style: TextStyle().copyWith(
    //               fontSize: 16.0,
    //               fontFamily: 'Kanit',
    //               fontWeight: FontWeight.normal,
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //     todayDayBuilder: (context, date, _) {
    //       return Container(
    //         margin: const EdgeInsets.all(5.0),
    //         padding: const EdgeInsets.only(top: 5.0, left: 5.0),
    //         color: Colors.amber[400],
    //         width: 100,
    //         height: 100,
    //         child: Text(
    //           '${date.day}',
    //           style: TextStyle().copyWith(
    //             fontSize: 16.0,
    //             fontFamily: 'Kanit',
    //             fontWeight: FontWeight.normal,
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    //   onVisibleDaysChanged: _onVisibleDaysChanged,
    //   onCalendarCreated: _onCalendarCreated,
    // );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return Container();

    // fixflutter2 TableCalendar(
    //   locale: 'th_th',
    //   calendarController: _calendarController,
    //   events: _events,
    //   // holidays: _holidays,
    //   initialCalendarFormat: CalendarFormat.month,
    //   formatAnimation: FormatAnimation.slide,
    //   startingDayOfWeek: StartingDayOfWeek.sunday,
    //   availableGestures: AvailableGestures.all,
    //   availableCalendarFormats: const {
    //     CalendarFormat.month: '',
    //     CalendarFormat.week: '',
    //   },
    //   calendarStyle: CalendarStyle(
    //     outsideDaysVisible: true,
    //     weekendStyle: TextStyle().copyWith(
    //       color: Color(0xFFdec6c6),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //     holidayStyle: TextStyle().copyWith(
    //       color: Color(0xFFC5DAFC),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //   ),
    //   daysOfWeekStyle: DaysOfWeekStyle(
    //     weekendStyle: TextStyle().copyWith(
    //       color: Color(0xFFdec6c6),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //     weekdayStyle: TextStyle().copyWith(
    //       color: Color(0xFFC5DAFC),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //     ),
    //   ),
    //   headerStyle: HeaderStyle(
    //     centerHeaderTitle: true,
    //     formatButtonVisible: false,
    //     titleTextStyle: TextStyle().copyWith(
    //       color: Color(0xFFa7141c),
    //       fontFamily: 'Kanit',
    //       fontWeight: FontWeight.normal,
    //       fontSize: 18.0,
    //     ),
    //   ),
    //   builders: CalendarBuilders(
    //     selectedDayBuilder: (context, date, _) {
    //       return FadeTransition(
    //         opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
    //         child: Container(
    //           margin: const EdgeInsets.all(5.0),
    //           padding: const EdgeInsets.only(top: 5.0, left: 5.0),
    //           color: Color(0xFFC5DAFC),
    //           width: 100,
    //           height: 100,
    //           child: Text(
    //             '${date.day}',
    //             style: TextStyle().copyWith(
    //               fontSize: 16.0,
    //               fontFamily: 'Kanit',
    //               fontWeight: FontWeight.normal,
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //     todayDayBuilder: (context, date, _) {
    //       return Container(
    //         margin: const EdgeInsets.all(5.0),
    //         padding: const EdgeInsets.only(top: 5.0, left: 5.0),
    //         color: Colors.amber[400],
    //         width: 100,
    //         height: 100,
    //         child: Text(
    //           '${date.day}',
    //           style: TextStyle().copyWith(
    //             fontSize: 16.0,
    //             fontFamily: 'Kanit',
    //             fontWeight: FontWeight.normal,
    //           ),
    //         ),
    //       );
    //     },
    //     markersBuilder: (context, date, events, holidays) {
    //       final children = <Widget>[];

    //       if (events.isNotEmpty) {
    //         children.add(
    //           Positioned(
    //             right: 1,
    //             bottom: 1,
    //             child: _buildEventsMarker(date, events),
    //           ),
    //         );
    //       }

    //       if (holidays.isNotEmpty) {
    //         children.add(
    //           Positioned(
    //             right: -2,
    //             top: -2,
    //             child: _buildHolidaysMarker(),
    //           ),
    //         );
    //       }

    //       return children;
    //     },
    //   ),
    //   onDaySelected: (date, events, holidays) {
    //     _onDaySelected(date, events, holidays);
    //     _animationController.forward(from: 0.0);
    //   },
    //   onVisibleDaysChanged: _onVisibleDaysChanged,
    //   onCalendarCreated: _onCalendarCreated,
    // );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        // fixflutter2 color: _calendarController.isSelected(date)
        //     ? Color(0xFFa7141c)
        //     : _calendarController.isToday(date)
        //         ? Color(0xFFa7141c)
        //         : Color(0xFFa7141c),
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList() {
    double width = MediaQuery.of(context).size.width;

    return ListView(
      children: _selectedEvents
          .map(
            (event) => Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventCalendarForm(
                        url: '${eventCalendarApi}read',
                        code: event['code'],
                        model: event,
                        urlComment: eventCalendarCommentApi,
                        urlGallery: eventCalendarGalleryApi,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(bottom: 5.0),
                          height: 100,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                padding: EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 90,
                                          width: 90,
                                          child: Container(
                                            child: loadingImageNetwork(
                                              '${event['imageUrl']}',
                                              fit: BoxFit.cover,
                                            ),
                                            //     Image.network(
                                            //   '${event['imageUrl']}',
                                            //   fit: BoxFit.cover,
                                            // ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width * 60 / 100,
                                          margin:
                                              EdgeInsets.fromLTRB(8, 0, 0, 0),
                                          child: Text(
                                            '${event['title']}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontFamily: 'Kanit',
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(8, 0, 0, 0),
                                          child: Text(
                                            event['dateStart'] != '' &&
                                                    event['dateEnd'] != ''
                                                ? dateStringToDate(
                                                        event['dateStart']) +
                                                    " - " +
                                                    dateStringToDate(
                                                        event['dateEnd'])
                                                : 'dd',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontFamily: 'Kanit',
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
