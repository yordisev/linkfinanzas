import 'package:codigoqr/screen/claves.dart';
import 'package:codigoqr/screen/mislinks.dart';
import 'package:codigoqr/screen/finanzas.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  PageController _pageController = PageController();
  int selectedPage = 0;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [buildPageView(), buildBottomNav()])),
    );
  }

  Widget buildPageView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: PageView(
        controller: _pageController,
        children: [FinanzasScreen(), LinksScreen(), ClavesScreen()],
        onPageChanged: (index) {
          onPageChange(index);
        },
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedPage,
      backgroundColor: Colors.green,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.monetization_on_outlined,
            size: 35,
          ),
          activeIcon: Icon(Icons.monetization_on_outlined, size: 40),
          label: 'Finanzas',
          // backgroundColor: colors.tertiary,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.link_sharp,
            size: 35,
          ),
          activeIcon: Icon(Icons.link_sharp, size: 40),
          label: 'Links',
          // backgroundColor: colors.tertiary,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.key,
            size: 35,
          ),
          activeIcon: Icon(Icons.key, size: 40),
          label: 'Claves',
          // backgroundColor: colors.tertiary,
        ),
      ],
      onTap: (int index) {
        _pageController.animateToPage(index,
            duration: Duration(microseconds: 1000), curve: Curves.easeIn);
      },
    );
  }

  onPageChange(int index) {
    setState(() {
      selectedPage = index;
    });
  }
}
