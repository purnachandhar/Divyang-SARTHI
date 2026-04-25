import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AppTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;
  final String? title;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withOpacity(0.05)),
              dataRowMaxHeight: 70,
              dataRowMinHeight: 60,
              columnSpacing: 24,
              horizontalMargin: 24,
              columns: columns.map((col) => DataColumn(
                label: Text(
                  col,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              )).toList(),
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }
}
