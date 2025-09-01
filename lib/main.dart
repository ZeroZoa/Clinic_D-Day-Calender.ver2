import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() => runApp(const MyApp()); // 앱 실행 시작점

// 최상위 앱 위젯 정의
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Day 계산기',
      //theme: ThemeData(primarySwatch: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: const DDayCalculatorPage(),
      locale: const Locale('ko'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
    );
  }
}

// 상태가 있는 위젯: D-Day 계산 화면
class DDayCalculatorPage extends StatefulWidget {
  const DDayCalculatorPage({super.key});

  @override
  State<DDayCalculatorPage> createState() => _DDayCalculatorPageState();
}

class _DDayCalculatorPageState extends State<DDayCalculatorPage> {
  // 시작일: 오늘 날짜로 초기화
  DateTime _startDate = DateTime.now();

  // 종료일: 시작일 기준 90일 후로 초기화
  DateTime _endDate = DateTime.now().add(
    const Duration(days: 90),
  );

  // 종료일이 시작일보다 빠를 때 표시할 오류 메시지
  String? _errorMessage;

  // 날짜를 yyyy-MM-dd 형식으로 포맷하는 객체
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  // 날짜 선택 다이얼로그를 띄우는 함수
  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate, // 초기값 설정
      firstDate: DateTime(2000),                    // 최소 선택일
      lastDate: DateTime(2100),                     // 최대 선택일
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // 종료일이 시작일보다 이전일 경우 오류 메시지 설정
          if (_endDate.isBefore(_startDate)) {
            _errorMessage = '종료일은 시작일 이후여야 합니다.';
          } else {
            _errorMessage = null; // 오류 없음
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _errorMessage = '종료일은 시작일 이후여야 합니다.';
          } else {
            _errorMessage = null;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 시작일과 종료일 간의 일 수 차이 계산(오늘도 포함)
    final int dDay = _endDate.difference(_startDate).inDays + 1;

    return Scaffold(
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(20), // 화면 전체 여백
            child: Row(
              children: [
                const SizedBox(height: 10), // 상단 여백
                // 시작일 표시 및 선택 버튼
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //시작일 파트 시작
                    Padding(
                        padding: const EdgeInsets.only(left: 15, top: 15),
                        child: Row(
                            children: [
                              Text('시작일', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 20),
                              Text(_formatter.format(_startDate),style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () => _selectDate(isStart: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo, // 배경색
                                  foregroundColor: Colors.white,  // 글자색
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                child: const Text('날짜 선택'),
                              ),
                            ]
                        )
                    ),
                    //시작일 파트 끝
                    const SizedBox(height: 15),
                    //종료일 파트 시작
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text('종료일', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 20),
                          Text(_formatter.format(_endDate), style: TextStyle(fontSize: 24)),  // 선택된 날짜 표시
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 330,
                          width: 400,
                          child: CalendarDatePicker(
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            onDateChanged: (picked) {
                              setState(() {
                                _endDate = picked;
                                if (_endDate.isBefore(_startDate)) {
                                  _errorMessage = '종료일은 시작일 이후여야 합니다.';
                                } else {
                                  _errorMessage = null;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    //종료일 파트 끝
                    //디데이 파트 시작
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child:Container(
                        height: 2,
                        width: 355, // 전체 너비 채움
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: _errorMessage != null
                          ? Text(
                        _errorMessage!, // 오류 메시지 표시
                        style: const TextStyle(color: Colors.red),
                      )
                          : Text(
                        '디데이 $dDay일', // 디데이 결과 표시
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                //디데이 파트 끝
                //단위 별 용량 파트 시작
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //단위 인디케이터
                      _buildUnitContainer('2.5단위', dDay * 0.08333333333, [Colors.amber.shade100, Colors.amber.shade50], 2.5, context),
                      _buildUnitContainer('3단위', dDay * 0.1, [Colors.orange.shade100, Colors.orange.shade50],3, context),
                      _buildUnitContainer('4단위', dDay * 0.125, [Colors.green.shade100, Colors.green.shade50], 4, context),
                      _buildUnitContainer('4.3단위', dDay * 0.1428571429, [Colors.teal.shade100, Colors.teal.shade50], 4.3, context),
                      _buildUnitContainer('5단위', dDay * 0.1666666666, [Colors.blue.shade100, Colors.blue.shade50], 5, context),
                      _buildUnitContainer('6단위', dDay * 0.2, [Colors.purple.shade100, Colors.purple.shade50], 6, context),
                      _buildUnitContainer('7.5단위', dDay * 0.25, [Colors.pink.shade100, Colors.pink.shade50], 7.5, context),
                      const SizedBox(height: 20),

                      //처방 멘트 복사 버튼
                      Row(
                        children: [
                          const SizedBox(width: 181),
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: '호르몬 처방으로 아이동반 내원 D C'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('아이동반이 복사되었습니다')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('아이동반'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                      //단위별 용량 파트 및 클립보드 복사 끝
                    ],
                  ),
                ),
              ],
            ),
          ),
      )
    );
  }
}

Widget _buildUnitContainer(String label, double value, List<Color> gradientColors, double degree, BuildContext context) {
  return Row(
    children: [
      TextButton( // 수정: Container를 버튼으로 대체
        onPressed: () {
          String degreeStr = (degree % 1 == 0) ? degree.toInt().toString() : degree.toString();
          Clipboard.setData(ClipboardData(
            text: 'D C ($degreeStr단위) > 호르몬: 개 처방부탁드려요. (호르몬: 개  보유중)'
          ));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$degreeStr 먹는 약X 클립보드에 복사되었습니다')),
          );
        },
        style: TextButton.styleFrom( // 수정: 버튼 스타일 설정
          padding: EdgeInsets.zero, // 내부 Container의 패딩 유지
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          width: 220,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()], // 숫자폭 일정
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                '→   ${value.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 10,
      ),
      ElevatedButton.icon(
        onPressed: () {
          String degreeStr = (degree % 1 == 0) ? degree.toInt().toString() : degree.toString();
          Clipboard.setData(ClipboardData(
            text: 'D C ($degreeStr단위) > 호르몬: 개 먹는 약: 처방부탁드려요. (호르몬: 개  , 먹는 약: 보유중)'
            )
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$degreeStr 먹는 약O 클립보드에 복사되었습니다')),
          );
        },
        icon: const Icon(Icons.radio_button_unchecked, size: 14), // 아이콘 크기 줄임
        label: const Text(
          '먹는 약',
          style: TextStyle(fontSize: 12), // 폰트 크기 줄임
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          textStyle: const TextStyle(fontSize: 8), // 버튼 전체 폰트 크기(예비)
        )
      ),
    ],
  );
}

