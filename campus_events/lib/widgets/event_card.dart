import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/format.dart';

/// R18: the one reusable card. Avatar stack on the left, expanded text
/// column, favourite button on the right.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = item.category.color(scheme);

    // R5: destructure the record where it is shown.
    final (free: left, taken: _) = item.places;
    // R19: "FULL", "N left" when 5 or fewer remain, nothing otherwise.
    final String? badge = item.isFull
        ? 'FULL'
        : (left <= 5 ? '$left left' : null);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(item.category.icon, color: color),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: item.isFull
                              ? scheme.error
                              : scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: item.isFull
                                  ? scheme.onError
                                  : scheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(item.startsAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      item.online ? 'Online' : item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: item.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(
                  item.favourite ? Icons.favorite : Icons.favorite_border,
                  color: item.favourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
