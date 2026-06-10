import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.selectedMajor});

  final String selectedMajor;

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _isSelected = '';
  String _searchText = '';
  bool _isChanged = false;

  final Map<String, List<String>> majorMap = {
    "미래엔지니어링융합대학": [
      "ICT융합학부",
      '미래모빌리티공학부',
      '신소재반도체융합학부',
      '전기전자융합학부',
      '바이오매디컬헬스학부'
    ],
    '스마트도시융합대학': ['건축도시환경학부', '디자인융합학부', '스포츠과학부'],
    '경영·공공정책대학': ['경영경제융합학부'],
    '인문예술대학': ['글로벌인문학부', '예술학부'],
    '아산아너스칼리지': ['자율전공학부'],
    "IT융합학부": ["IT융합전공", "AI융합전공"],
  };

  // ✅ init에서 저장된 대표 전공을 우선으로 로드
  Future<void> _loadMainMajor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMainMajor = prefs.getString(kMainMajorKey);

    if (!mounted) return;
    setState(() {
      _isSelected = (savedMainMajor != null && savedMainMajor.isNotEmpty)
          ? savedMainMajor
          : widget.selectedMajor; // fallback
    });
  }

  // ✅ 여기서 바꾸면 대표 전공(kMainMajorKey) 덮어쓰기 저장
  Future<void> _saveMainMajor(String major) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kMainMajorKey, major);
  }

  Widget SearchForm() {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: TextFormField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: const InputDecoration(
              hintText: "알림 받을 학과를 입력해주세요",
              hintStyle: TextStyle(color: Color(0xffA3A3A3)),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 5),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {},
            child: const Text('검색', style: TextStyle(color: Color(0xff009D72))),
          ),
        )
      ],
    );
  }

  Widget Selector(String name) {
    return Container(
      margin: const EdgeInsets.only(top: 36),
      child: Row(
        children: [
          Text(name, style: const TextStyle(fontSize: 17)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_isSelected != name) {
                  _isChanged = true;
                  _isSelected = name;
                }
              });
            },
            child: _isSelected == name
                ? SvgPicture.asset('assets/icons/알림it_checkButton_O.svg')
                : SvgPicture.asset('assets/icons/알림it_checkButton_X.svg'),
          )
        ],
      ),
    );
  }

  Future<void> _finish() async {
    if (_isSelected.isEmpty) return;

    // ✅ 변경 여부와 무관하게 현재 선택값을 대표 전공으로 저장(덮어쓰기)
    await _saveMainMajor(_isSelected);

    // ✅ MainPage로 새로 push하지 말고 pop으로 결과 전달
    // MainPage에서는 await Navigator.push(...)로 result를 받아 selectedMajor 갱신하면 됨
    if (!mounted) return;
    Navigator.pop(context, {
      "selectedMajor": _isSelected,
      "changed": _isChanged,
    });
  }

  @override
  void initState() {
    super.initState();
    _isSelected = widget.selectedMajor; // 일단 기본값
    _loadMainMajor(); // ✅ prefs 값 있으면 덮어씌움
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filteredList = [];
    majorMap.forEach((faculty, majors) {
      final matchedMajors = majors.where((m) => m.contains(_searchText)).toList();
      if (matchedMajors.isNotEmpty) {
        filteredList.add(Text(
          faculty,
          style: const TextStyle(
            color: Color(0xff009D72),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ));
        filteredList.addAll(matchedMajors.map((major) => Selector(major)));
        filteredList.add(const SizedBox(height: 60));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 100, 30, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _finish, // ✅ 뒤로도 완료와 동일하게 처리(원하면 Navigator.pop만도 가능)
                  child: const Text(
                    '⟨ 전공 선택',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                const Spacer(),
                if (_isSelected.isNotEmpty)
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff009D72),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            SearchForm(),
            Container(height: 2, color: const Color(0xff009D72)),
            const SizedBox(height: 60),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: filteredList,
              ),
            ),
          ],
        ),
      ),
    );
  }
}