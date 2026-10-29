import 'package:material_ui/material_ui.dart';
import 'package:stutz/core/utils/amount_parser.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';

class DashboardAmountPair extends StatelessWidget {
  final int actualMinor;
  final int plannedMinor;
  final TextStyle? style;

  const DashboardAmountPair({
    super.key,
    required this.actualMinor,
    required this.plannedMinor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        '${formatChfMinor(actualMinor)} / ${formatChfMinor(plannedMinor)}',
        maxLines: 1,
        softWrap: false,
        style: style,
      ),
    );
  }
}

class DashboardProgressBar extends StatelessWidget {
  final DashboardProgress progress;
  final double height;

  const DashboardProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isOver = progress.expectedMinor == null
        ? progress.isOverBudget
        : progress.isOverPace;
    final bar = LinearProgressIndicator(
      value: progress.ratio.clamp(0.0, 1.0).toDouble(),
      minHeight: height,
      borderRadius: BorderRadius.circular(height / 2),
      color: isOver ? colors.error : colors.primary,
      backgroundColor: colors.surfaceContainerHighest,
    );
    if (progress.expectedMinor == null || progress.plannedMinor <= 0) {
      return bar;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final position = (progress.expectedMinor! / progress.plannedMinor)
            .clamp(0.0, 1.0);
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            bar,
            Positioned(
              left: (constraints.maxWidth - 3) * position,
              child: Container(
                width: 3,
                height: height,
                color: colors.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DashboardPaceLabel extends StatelessWidget {
  final DashboardProgress progress;

  const DashboardPaceLabel({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Budget bis heute: ${formatChfMinor(progress.expectedMinor!)}',
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: progress.isOverPace
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
