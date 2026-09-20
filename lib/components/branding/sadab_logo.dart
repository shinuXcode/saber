import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/data/prefs.dart';

class SadabLogo extends StatelessWidget {
  const SadabLogo({super.key, this.size = 48, this.variant});

  final double size;
  final String? variant;

  static const variants = ['default', 'dark', 'light', 'minimal', 'outline'];

  String _asset(BuildContext context) {
    final selected = variant ?? stows.logoVariant.value;
    final safe = variants.contains(selected) ? selected : 'default';
    return 'assets/images/branding/sadab-$safe.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset(context),
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: 'Sadab A logo',
    );
  }
}

class SadabLogoSelector extends StatelessWidget {
  const SadabLogoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stows.logoVariant,
      builder: (context, value, _) => DropdownButtonFormField<String>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: 'App logo style',
          prefixIcon: Icon(Icons.auto_awesome),
        ),
        items: const [
          DropdownMenuItem(value: 'default', child: Text('Default')),
          DropdownMenuItem(value: 'dark', child: Text('Dark')),
          DropdownMenuItem(value: 'light', child: Text('Light')),
          DropdownMenuItem(value: 'minimal', child: Text('Minimal')),
          DropdownMenuItem(value: 'outline', child: Text('Outline')),
        ],
        onChanged: (next) {
          if (next != null) stows.logoVariant.value = next;
        },
      ),
    );
  }
}
