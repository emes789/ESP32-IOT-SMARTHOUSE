import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensors_provider.dart';
import '../core/theme/app_colors.dart';

class DataSourceIndicator extends StatelessWidget {
  final bool showLabel;
  final bool compact;
  const DataSourceIndicator({super.key, this.showLabel = true, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorsProvider>(
      builder: (context, provider, child) {
        final isRealDevice = provider.isRealDeviceConnected;
        final sourceName = provider.dataSourceName;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 6 : 10,
              height: compact ? 6 : 10,
              decoration: BoxDecoration(
                color: isRealDevice ? AppColors.success : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            if (showLabel) ...[
              SizedBox(width: compact ? 4 : 6),
              Container(
                constraints: BoxConstraints(maxWidth: compact ? 70 : 150),
                child: Text(
                  sourceName,
                  style: TextStyle(
                    fontSize: compact ? 8 : 12,
                    color: isRealDevice ? AppColors.success : AppColors.warning,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}