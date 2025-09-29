import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 수정: DDayCalculatorApp 위젯을 직접 실행하도록 변경
void main() => runApp(const DDayCalculatorApp());

// 수정: MyApp과 DDayCalculatorPage를 하나로 합친 StatefulWidget
class DDayCalculatorApp extends StatefulWidget {
  const DDayCalculatorApp({super.key});

  @override
  State<DDayCalculatorApp> createState() => _DDayCalculatorAppState();
}

// 수정: 기존 _DDayCalculatorPageState의 모든 로직을 포함하는 State 클래스
class _DDayCalculatorAppState extends State<DDayCalculatorApp> {
  // 기존의 모든 상태 변수와 메서드를 그대로 가져옴
  late DateTime _startDate;
  late DateTime _endDate;
  String? _errorMessage;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    // initState에서 다른 인스턴스 변수를 사용하여 초기화
    _endDate = DateTime(_startDate.year, _startDate.month + 3, _startDate.day);
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        // 날짜 유효성 검사
        if (_endDate.isBefore(_startDate)) {
          _errorMessage = '종료일은 시작일 이후여야 합니다.';
        } else {
          _errorMessage = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int dDay  = _endDate.difference(_startDate).inDays + 1;

    return MaterialApp(
      title: 'D-Day 계산기',
      debugShowCheckedModeBanner: false,
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

      home: Scaffold(
        body: InteractiveViewer(
          boundaryMargin: const EdgeInsets.only(
            right: 1000000,
            bottom: 1000000,
          ),
          child: OverflowBox(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 15, top: 15),
                          child: Row(children: [
                            const Text('시작일', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 20),
                            Text(_formatter.format(_startDate),
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () => _selectDate(isStart: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text('날짜 선택'),
                            ),
                          ])),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Row(
                          children: [
                            const Text('종료일', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 20),
                            Text(_formatter.format(_endDate),
                                style: const TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
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
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          height: 2,
                          width: 355,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min, // Row 자체의 크기도 자식의 크기에 맞게 최소화
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: _errorMessage != null
                                ? Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            )
                                : Text(
                              '디데이 $dDay일',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUnitContainer('2.5단위', dDay * 0.08333333333,
                            [Colors.amber.shade100, Colors.amber.shade50], 2.5, context),
                        _buildUnitContainer('3단위', dDay * 0.1,
                            [Colors.orange.shade100, Colors.orange.shade50], 3, context),
                        _buildUnitContainer('4단위', dDay * 0.125,
                            [Colors.green.shade100, Colors.green.shade50], 4, context),
                        _buildUnitContainer('4.3단위', dDay * 0.1428571429,
                            [Colors.teal.shade100, Colors.teal.shade50], 4.3, context),
                        _buildUnitContainer('5단위', dDay * 0.1666666666,
                            [Colors.blue.shade100, Colors.blue.shade50], 5, context),
                        _buildUnitContainer('6단위', dDay * 0.2,
                            [Colors.purple.shade100, Colors.purple.shade50], 6, context),
                        _buildUnitContainer('7.5단위', dDay * 0.25,
                            [Colors.pink.shade100, Colors.pink.shade50], 7.5, context),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(
                                    text: 'D C > 결과지 장 처방 부탁드립니다'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('결과지가 복사되었습니다')),
                                );
                              },
                              icon: const Icon(Icons.copy),
                              label: const Text('결과지'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(width: 16,),
                            ElevatedButton.icon(
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(
                                    text: '호르몬 처방으로 아이동반 내원 D C'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('아이동반이 복사되었습니다')),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  // _buildUnitContainer는 State 클래스의 멤버 메서드로 위치 변경
  Widget _buildUnitContainer(String label, double value,
      List<Color> gradientColors, double degree, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            String degreeStr =
            (degree % 1 == 0) ? degree.toInt().toString() : degree.toString();
            Clipboard.setData(ClipboardData(
                text: 'D C ($degreeStr단위) > 호르몬: 개 처방부탁드려요. (호르몬: 개  보유중)'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$degreeStr 먹는 약X 클립보드에 복사되었습니다')),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      fontFeatures: [FontFeature.tabularFigures()],
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
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
            onPressed: () {
              String degreeStr = (degree % 1 == 0)
                  ? degree.toInt().toString()
                  : degree.toString();
              Clipboard.setData(ClipboardData(
                  text:
                  'D C ($degreeStr단위) > 호르몬: 개, 먹는 약: 일치 처방부탁드려요. (호르몬: 개, 먹는 약: 일치 보유)'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$degreeStr 먹는 약O 클립보드에 복사되었습니다')),
              );
            },
            icon: const Icon(Icons.radio_button_unchecked, size: 14),
            label: const Text(
              '먹는 약',
              style: TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                textStyle: const TextStyle(fontSize: 8))),
      ],
    );
  }
}
