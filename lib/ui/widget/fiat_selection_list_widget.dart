import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../util/extension/extension.dart';
import '../../util/l10n.dart';
import '../../util/r.dart';
import '../../wyre/wyre_vo.dart';
import 'brightness_observer.dart';
import 'search_header_widget.dart';

class FiatSelectionListWidget extends HookWidget {
  const FiatSelectionListWidget({
    Key? key,
    required this.fiatList,
    required this.onTap,
    this.selectedFiat,
  }) : super(key: key);

  final List<WyreFiat> fiatList;
  final FiatSelectCallback onTap;
  final WyreFiat? selectedFiat;

  @override
  Widget build(BuildContext context) {
    final selectedFiat = this.selectedFiat ?? fiatList[0];
    final filterList = useState<List<WyreFiat>>(fiatList);

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: SearchHeaderWidget(
                hintText: context.l10n.search,
                onChanged: (k) {
                  if (k.isNotEmpty) {
                    filterList.value = fiatList
                        .where((e) => e.name.containsIgnoreCase(k))
                        .toList();
                  } else {
                    filterList.value = fiatList;
                  }
                },
              )),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.value.length,
              itemBuilder: (BuildContext context, int index) => _Item(
                fiat: filterList.value[index],
                selectedFiat: selectedFiat,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.fiat,
    required this.selectedFiat,
    required this.onTap,
  }) : super(key: key);

  final WyreFiat fiat;
  final WyreFiat selectedFiat;
  final FiatSelectCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: context.colorScheme.background,
      child: InkWell(
        onTap: () {
          onTap(fiat);
          Navigator.pop(context);
        },
        child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(children: [
              ClipOval(
                  child: Image.asset(
                fiat.flag,
                width: 40,
                height: 40,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                      fiat.name,
                      style: TextStyle(
                        color: context.colorScheme.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(fiat.desc,
                        style: TextStyle(
                          color: context.colorScheme.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                  ])),
              if (selectedFiat.name == fiat.name)
                Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(R.resourcesIcCheckSvg),
                ),
            ])),
      ));
}

typedef FiatSelectCallback = void Function(WyreFiat);
