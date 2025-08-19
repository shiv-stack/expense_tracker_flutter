import 'package:expensely_app/Screens/profile_screen.dart';
import 'package:expensely_app/constants/colors.dart';

import 'package:expensely_app/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'package:expensely_app/Screens/Add_Expense.dart';
import 'package:expensely_app/Screens/Chart_Screen.dart';
import 'package:expensely_app/bloc/expense_bloc.dart';
import 'package:expensely_app/bloc/expense_event.dart';
import 'package:expensely_app/bloc/expense_state.dart';
import 'package:expensely_app/constants/extensions.dart';
import 'package:expensely_app/models/transaction.dart';
import 'package:expensely_app/utils/icon_map.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// The new main widget that holds the persistent navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isAddExpenseOpen = false;

  late PersistentTabController _controller;
  int selectedIndex = 0;
  String get userName => SharedPrefService.getData("userName") ?? "User";
  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: DashboardTab(
            userName: userName,
            onAddOrEditExpense: (value) {
              setState(() {
                _isAddExpenseOpen = value;
              });
            },
          ),
          item: ItemConfig(
            icon: Icon(Icons.home_rounded),
            // Image.asset(
            //   'assets/home.png',
            //   width: 24,
            //   height: 24,
            //   color: selectedIndex == 0 ? primaryColor : Colors.grey,
            // ),
            title: "Home",
            activeForegroundColor: primaryColor,
            inactiveBackgroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: const ReportScreen(), // Your existing Chart_Screen
          item: ItemConfig(
            icon: Icon(Icons.bar_chart_rounded),
            //  Image.asset(
            //   'assets/analytics.png',
            //   width: 24,
            //   height: 24,
            //   color: selectedIndex == 1 ? primaryColor : Colors.grey,
            // ),
            title: "Reports",
            activeForegroundColor: primaryColor,
            inactiveBackgroundColor: Colors.grey,
          ),
        ),
        PersistentTabConfig(
          screen: ProfileScreen(), // Placeholder for Profile
          item: ItemConfig(
            icon: Icon(Icons.person_rounded),
            // Image.asset(
            //   'assets/profile.png',
            //   width: 24,
            //   height: 24,
            //   color: selectedIndex == 2 ? primaryColor : Colors.grey,
            // ),
            title: "Profile",
            activeForegroundColor: primaryColor,
            inactiveBackgroundColor: Colors.grey,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) => PersistentTabView(
        controller: _controller,
        onTabChanged: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        backgroundColor: offWhiteColor,
        tabs: _tabs(),
        navBarBuilder: (navBarConfig) => Style6BottomNavBar(
          navBarConfig: navBarConfig,
          height: 60,
          navBarDecoration: NavBarDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            // borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButton: (selectedIndex == 0 && !_isAddExpenseOpen)
            ? FloatingActionButton.extended(
                extendedPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                label: Text("Add Expense", style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExpenseAnimatedScreen()),
                  );
                },
                backgroundColor: primaryColor,
                // child: cons,
              )
            : null,
      );
}

/// This widget contains your original HomeScreen UI (the dashboard).
class DashboardTab extends StatefulWidget {
  final String userName;
  final void Function(bool value) onAddOrEditExpense;

  const DashboardTab({super.key, required this.userName, required this.onAddOrEditExpense});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with SingleTickerProviderStateMixin {
  bool isFilterApplied = false;
  String selectedMonth = DateFormat.MMMM().format(DateTime.now());
  int selectedYear = DateTime.now().year;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    context.read<ExpenseBloc>().add(LoadTransactions());
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    return groupBy(transactions, (t) => DateFormat('yyyy-MM-dd').format(t.date));
  }

  String _formatDateHeader(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: offWhiteColor,
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final transactions = state.transactions.where((t) {
            if (isFilterApplied) {
              final selectedMonthIndex = DateFormat.MMMM().parse(selectedMonth).month;
              return t.date.month == selectedMonthIndex && t.date.year == selectedYear;
            }
            return t.date.month == DateTime.now().month && t.date.year == DateTime.now().year;
          }).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final groupedTransactions = _groupTransactionsByDate(transactions);
          final sortedDates = groupedTransactions.keys.toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(transactions)),
              if (transactions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No transactions for this period.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ),
                )
              else
                ..._buildGroupedTransactionSlivers(groupedTransactions, sortedDates),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for FAB
            ],
          );
        },
      ),
    );
  }

  // All your helper methods (_buildHeader, _buildGroupedTransactionSlivers, etc.) remain here

  Widget _buildHeader(List<Transaction> transactions) {
    var totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    var totalExpenses = transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    var totalBalance = totalIncome - totalExpenses;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => showFilterBottomSheet(context),
                  ),
                  if (isFilterApplied)
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isFilterApplied = false;
                          selectedMonth = DateFormat.MMMM().format(DateTime.now());
                          selectedYear = DateTime.now().year;
                        });
                        context.read<ExpenseBloc>().add(LoadTransactions());
                      },
                    ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF127A64),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Balance", style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "${SharedPrefService.getCurrency()} ${totalBalance.formatWithCommas()}",
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white12,
                            child: Icon(Icons.arrow_downward, size: 18, color: Colors.green)),
                        const SizedBox(height: 5),
                        Text("${SharedPrefService.getCurrency()} ${totalIncome.formatWithCommas()}",
                            style: const TextStyle(color: Colors.white)),
                        const Text("Income", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Column(
                      children: [
                        const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white12,
                            child: Icon(Icons.arrow_upward, size: 18, color: Colors.red)),
                        const SizedBox(height: 5),
                        Text("${SharedPrefService.getCurrency()} ${totalExpenses.formatWithCommas()}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        const Text("Expenses", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedTransactionSlivers(
      Map<String, List<Transaction>> groupedTransactions, List<String> sortedDates) {
    return sortedDates.map((dateKey) {
      final transactionsOnDate = groupedTransactions[dateKey]!;
      final double dailyIncome =
          transactionsOnDate.where((t) => t.isIncome).fold(0.0, (sum, item) => sum + item.amount);
      final double dailyExpense =
          transactionsOnDate.where((t) => !t.isIncome).fold(0.0, (sum, item) => sum + item.amount);
      return SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            key: ValueKey(SharedPrefService.getCurrency()),
            delegate: _SliverDateHeaderDelegate(
              title: _formatDateHeader(dateKey),
              totalIncome: dailyIncome,
              totalExpense: dailyExpense,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final transaction = transactionsOnDate[index];
                return _buildTransaction(
                  transaction.title,
                  DateFormat.MMMd().format(transaction.date), // "Aug 04"
                  "${transaction.isIncome ? '+' : '-'} ${SharedPrefService.getCurrency()} ${transaction.amount.formatWithCommas()}",
                  transaction.isIncome ? Colors.green : Colors.red,
                  transaction.note,
                  transaction.category.name, transaction,
                );
              },
              childCount: transactionsOnDate.length,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTransaction(
    String title,
    String date,
    String amount,
    Color color,
    String note,
    String categoryName,
    Transaction transaction,
  ) {
    final icon = iconMap[categoryName.toLowerCase()] ?? Icons.category;
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              widget.onAddOrEditExpense(true);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddExpenseAnimatedScreen(
                          editingTx: transaction,
                        )),
              ).then((_) {
                widget.onAddOrEditExpense(false);
              });
            },
            //trigger update
            icon: Icons.edit,
            label: 'Edit',
            backgroundColor: Colors.blue,
          ),
          SlidableAction(
            onPressed: (context) {
              // Trigger delete event
              context.read<ExpenseBloc>().add(DeleteTransaction(transaction.id));
            },
            icon: Icons.delete,
            label: 'Delete',
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: getGradientForCategory(categoryName),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    note,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                amount,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LinearGradient getGradientForCategory(String category) {
    final List<LinearGradient> gradients = [
      const LinearGradient(colors: [Color(0xff64B5F6), Color(0xff1976D2)]),
      const LinearGradient(colors: [Color(0xff81C784), Color(0xff388E3C)]),
      const LinearGradient(colors: [Color(0xffE57373), Color(0xffD32F2F)]),
      const LinearGradient(colors: [Color(0xffFFB74D), Color(0xffF57C00)]),
      const LinearGradient(colors: [Color(0xffBA68C8), Color(0xff7B1FA2)]),
    ];
    final index = category.hashCode % gradients.length;
    return gradients[index];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning,";
    if (hour < 17) return "Good afternoon,";
    return "Good evening,";
  }

  void showFilterBottomSheet(BuildContext context) {
    String tempSelectedMonth = selectedMonth;
    int tempSelectedYear = selectedYear;

    List<String> months = DateFormat.MMMM().dateSymbols.MONTHS;
    List<int> years = List.generate(5, (index) => DateTime.now().year - index);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Filter Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: months.length,
                            itemBuilder: (context, index) {
                              final month = months[index];
                              final isSelected = tempSelectedMonth == month;
                              return ListTile(
                                title: Text(month,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    )),
                                trailing: isSelected ? const Icon(Icons.check, color: primaryColor) : null,
                                onTap: () {
                                  setSheetState(() {
                                    tempSelectedMonth = month;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: years.length,
                            itemBuilder: (context, index) {
                              final year = years[index];
                              final isSelected = tempSelectedYear == year;
                              return ListTile(
                                title: Text("$year",
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    )),
                                trailing: isSelected ? const Icon(Icons.check, color: primaryColor) : null,
                                onTap: () {
                                  setSheetState(() {
                                    tempSelectedYear = year;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: primaryColor)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              isFilterApplied = true;
                              selectedMonth = tempSelectedMonth;
                              selectedYear = tempSelectedYear;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Apply Filter"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// A delegate for creating sticky headers for each date group.
class _SliverDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;
  final double totalIncome;
  final double totalExpense;

  _SliverDateHeaderDelegate(
      {required this.title, required this.totalIncome, required this.totalExpense, this.height = 30.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Row(
            children: [
              if (totalIncome > 0)
                Text("Income: ${SharedPrefService.getCurrency()} ${totalIncome.formatWithCommas()}",
                    style: const TextStyle(color: Colors.green)),
              if (totalIncome > 0 && totalExpense > 0) const SizedBox(width: 10),
              if (totalExpense > 0)
                Text("Expense: ${SharedPrefService.getCurrency()} ${totalExpense.formatWithCommas()}",
                    style: const TextStyle(color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverDateHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        height != oldDelegate.height ||
        totalIncome != oldDelegate.totalIncome ||
        totalExpense != oldDelegate.totalExpense;
  }
}
