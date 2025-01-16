class FilterItem {
  final String filterType; // "Today", "This Week", "DateRange", etc.
  final bool filterStatus; // Optional toggle status
  final DateTime? startDate; // For date range filter
  final DateTime? endDate; // For date range filter

  FilterItem({
    required this.filterType,
    this.filterStatus = true,
    this.startDate,
    this.endDate,
  });
}
