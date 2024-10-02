import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final void Function(BuildContext context)? onBack;
  const Header(this.showBack, {this.onBack, super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 88,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 30),
                height: 64,
                color: Theme.of(context).colorScheme.secondary,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(showBack) Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if(onBack != null) {
                            onBack!(context);
                          } else {
                            context.go('/');
                          }
                         }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 2),
                      child: SvgPicture.asset("images/openvino_logo.svg"),
                    ),
                    const Text("TestDrive", style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                    )),
                  ],
                ),
              ),
              SvgPicture.asset("images/bit.svg"),
            ]
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(88);
}
