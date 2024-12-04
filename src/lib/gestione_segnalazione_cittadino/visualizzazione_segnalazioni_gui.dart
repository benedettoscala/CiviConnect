import 'package:civiconnect/theme.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../model/users_model.dart';

/// Gui to visualize reports list of citizen city
class ReportsViewCitizenGUI extends StatefulWidget {
  /// Constructor of [ReportsViewCitizenGUI]
  const ReportsViewCitizenGUI({super.key});

  @override
  State<ReportsViewCitizenGUI> createState() => _ReportsListCitizenState();
}

class _ReportsListCitizenState extends State<ReportsViewCitizenGUI> {

  // Variable State
  bool isEditing = false;
  Map<String, dynamic> userData = {};
  bool isLoading = true; // If data are loading
  late ThemeData theme;
  late TextStyle textStyle;
  late GenericUser userInfo;

  @override
  void initState() {
    super.initState();
    theme = ThemeManager().customTheme;
    textStyle = theme.textTheme.titleMedium!.copyWith(fontSize: 16);
    _loadUpdate();
  }

   void _loadUpdate(){
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: MediaQuery.of(context).size.width / 10),
                  child: Row(
                    children: [
                      Text('Benvenuto', style: Theme.of(context).textTheme.titleMedium),
                      const Expanded(child: UnconstrainedBox()),
                      IconButton(onPressed: (){}, icon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Theme.of(context).colorScheme.onPrimaryContainer))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }





}
