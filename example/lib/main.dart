import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:flutter_customizable_calendar/src/bloc/list_cubit/list_cubit.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final breaks = List.generate(
      7,
          (index) {
        final dayDate =
        DateUtils.addDaysToDate(today, index - today.weekday + 1);
        final isSunday = dayDate.weekday == DateTime.sunday;

        return Break(
          id: 'Break $index',
          start:
          isSunday ? dayDate : dayDate.add(const Duration(hours: 13)),
          duration:
          isSunday ? const Duration(days: 1) : const Duration(hours: 1),
          color: Colors.grey.withOpacity(0.25),
        );
      },
    );
    final events = [
      TaskDue(
        id: 'TaskDue 1',
        start: today.add(const Duration(hours: 13)),
      ),
      SimpleEvent(
        id: 'Event 2',
        start: today.add(const Duration(hours: 11, minutes: 59)),
        duration: const Duration(minutes: 30),
        title: 'Event 2',
      ),
      SimpleEvent(
        id: 'Event 1',
        start: today.add(const Duration(hours: 11, minutes: 59)),
        duration: const Duration(minutes: 40),
        title: 'Event 1',
      ),
      SimpleEvent(
        id: 'Event 3',
        start: today.add(const Duration(days: 2, hours: 10, minutes: 59)),
        duration: const Duration(minutes: 45),
        title: 'Event 3',
      ),
    ];

    return BlocProvider<ListCubit>(
      create: (context) => ListCubit()
        ..saveAll(
          events: events,
          breaks: breaks,
        ),
      child: MaterialApp(
        title: 'Flutter customizable calendar',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.blue.shade50,
        ),
        home: CalendarPage(
          breaks: List.generate(
            7,
            (index) {
              final dayDate =
                  DateUtils.addDaysToDate(today, index - today.weekday + 1);
              final isSunday = dayDate.weekday == DateTime.sunday;

              return Break(
                id: 'Break $index',
                start:
                    isSunday ? dayDate : dayDate.add(const Duration(hours: 13)),
                duration:
                    isSunday ? const Duration(days: 1) : const Duration(hours: 1),
                color: Colors.grey.withOpacity(0.25),
              );
            },
          ),
          events: [
            TaskDue(
              id: 'TaskDue 1',
              start: today.add(const Duration(hours: 13)),
            ),
            SimpleEvent(
              id: 'Event 2',
              start: today.add(const Duration(hours: 11, minutes: 59)),
              duration: const Duration(minutes: 30),
              title: 'Event 2',
            ),
            SimpleEvent(
              id: 'Event 1',
              start: today.add(const Duration(hours: 11, minutes: 59)),
              duration: const Duration(minutes: 40),
              title: 'Event 1',
            ),
            SimpleEvent(
              id: 'Event 3',
              start: today.add(const Duration(days: 2, hours: 10, minutes: 59)),
              duration: const Duration(minutes: 45),
              title: 'Event 3',
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPage<T extends FloatingCalendarEvent> extends StatefulWidget {
  const CalendarPage({
    super.key,
    this.breaks = const [],
    this.events = const [],
  });

  final List<Break> breaks;

  final List<T> events;

  @override
  State<CalendarPage<T>> createState() => _CalendarPageState<T>();
}

class _CalendarPageState<T extends FloatingCalendarEvent>
    extends State<CalendarPage<T>> with SingleTickerProviderStateMixin {
  final _daysViewController = DaysViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );
  final _weekViewController = WeekViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );
  final _monthViewController = MonthViewController(
    initialDate: _initialDate,
    endDate: _endDate,
  );
  late final TabController _tabController;
  late ThemeData _theme;

  // The initial date is 1970-01-01 in local time
  static DateTime get _initialDate => DateTime(1970);
  static DateTime? get _endDate => null;

  Map<int, CalendarController> get _controllers => {
        0: _daysViewController,
        1: _weekViewController,
        2: _monthViewController,
      };

  Map<int, String> get _segmentLabels => {
        0: CalendarView.days.name,
        1: CalendarView.week.name,
        2: CalendarView.month.name,
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        actions: [
          CupertinoButton(
            onPressed: () => _controllers[_tabController.index]?.reset(),
            child: Text(
              'Now',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _calendarViewPicker(),
            Expanded(child: _calendarViews()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _daysViewController.dispose();
    _weekViewController.dispose();
    _monthViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _calendarViewPicker() => StatefulBuilder(
        builder: (context, setState) => CupertinoSegmentedControl<int>(
          children: Map.fromEntries(
            List.generate(
              _tabController.length,
              (index) => MapEntry(index, _segment(index)),
            ),
          ),
          onValueChanged: (index) {
            _tabController.animateTo(index);
            setState(() {});
          },
          groupValue: _tabController.index,
        ),
      );

  Widget _segment(int index) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 20,
        ),
        child: Text(
          _segmentLabels[index]?.capitalized() ?? '???',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _calendarViews() => TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _daysView(),
          _weekView(),
          _monthView(),
        ],
      );

  Widget _daysView() => DaysView<T>(
        controller: _daysViewController,
        listCubit: context.read<ListCubit>(),
        monthPickerTheme: _periodPickerTheme,
        daysListTheme: DaysListTheme(
          itemTheme: DaysListItemTheme(
            foreground: _theme.primaryColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _theme.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        timelineTheme: TimelineTheme(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          timeScaleTheme: TimeScaleTheme(
            textStyle: _textStyle,
            currentTimeMarkTheme: _currentTimeMarkTheme,
          ),
          floatingEventsTheme: _floatingEventsTheme,
          draggableEventTheme: _draggableEventTheme,
        ),
        // breaks: widget.breaks,
        // events: widget.events,
        onDateLongPress: (obj){
          print(obj);
        },
        onEventTap: print,
        onEventUpdated: (obj){
          print(obj);
        },
      );

  Widget _weekView() => WeekView<T>(
        controller: _weekViewController,
        weekPickerTheme: _periodPickerTheme,
        divider: Divider(
          height: 2,
          thickness: 2,
          color: Colors.grey.withOpacity(0.33),
        ),
        daysRowTheme: DaysRowTheme(
          weekdayStyle: _textStyle,
          numberStyle: _textStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _theme.primaryColor,
          ),
        ),
        timelineTheme: TimelineTheme(
          padding: const EdgeInsets.symmetric(vertical: 32),
          timeScaleTheme: TimeScaleTheme(
            width: 48,
            currentTimeMarkTheme: _currentTimeMarkTheme,
            drawHalfHourMarks: false,
            drawQuarterHourMarks: false,
            hourFormatter: (time) => time.hour.toString(),
            textStyle: _textStyle,
            marksAlign: MarksAlign.center,
          ),
          floatingEventsTheme: _floatingEventsTheme,
          draggableEventTheme: _draggableEventTheme,
        ),
        breaks: widget.breaks,
        events: widget.events,
        onDateLongPress: print,
        onEventTap: print,
        onEventUpdated: print,
      );

  Widget _monthView() => MonthView<T>();

  TextStyle get _textStyle => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
      );

  DisplayedPeriodPickerTheme get _periodPickerTheme =>
      DisplayedPeriodPickerTheme(
        height: 40,
        foregroundColor: _theme.primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _theme.primaryColor),
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: TextStyle(
          color: _theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      );

  TimeMarkTheme get _currentTimeMarkTheme => TimeMarkTheme(
        length: 48,
        color: _theme.colorScheme.error,
      );

  FloatingEventsTheme get _floatingEventsTheme => FloatingEventsTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        margin: const EdgeInsets.all(1),
      );

  DraggableEventTheme get _draggableEventTheme => DraggableEventTheme(
        elevation: 5,
        sizerTheme: SizerTheme(
          decoration: BoxDecoration(
            color: _theme.colorScheme.error,
            shape: BoxShape.circle,
          ),
        ),
      );
}
