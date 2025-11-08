import 'package:cluck_care/app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cluck_care/features/restaurant/presentation/restaurant_screen.dart';
import 'package:cluck_care/core/app_flow/onboarding_service.dart';
import 'package:cluck_care/features/splash/presentation/splash_screen.dart';
import 'package:cluck_care/features/orders/controllers/orders_scope.dart';
import 'package:cluck_care/features/orders/presentation/order_details_screen.dart';
import 'package:cluck_care/core/app_flow/app_controllers.dart';
import 'package:cluck_care/core/cart/cart_scope.dart';
import 'package:cluck_care/features/billing/presentation/billing_screen.dart';
import 'package:cluck_care/features/menu/presentation/menu_screen.dart';
import 'package:cluck_care/data/repositories/staff_repository.dart';
import 'package:cluck_care/data/repositories/inventory_repository.dart';
import 'package:cluck_care/features/staff/presentation/staff_screen.dart';
import 'package:cluck_care/features/inventory/presentation/add_item_screen.dart';
import 'package:cluck_care/data/repositories/menu_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : (isTablet ? 24 : 20),
            vertical: isSmallScreen ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RestaurantScreen(),
                              ),
                            );
                          },
                          splashColor: AppColors.primaryCta.withOpacity(0.2),
                          highlightColor: AppColors.primaryCta.withOpacity(0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCta.withOpacity(0.35),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: AppColors.primaryCta.withOpacity(0.5), width: 1.2),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: isSmallScreen ? 18 : 22,
                              backgroundColor: AppColors.primaryCta.withOpacity(0.15),
                              child: Icon(
                                Icons.restaurant,
                                color: AppColors.primaryCta,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Juste Fried Chicken',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 6),
                          Text(
                            'Welcome Back!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  // Refresh button to reset onboarding and show onboarding flow again
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      tooltip: 'Reset onboarding',
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        await OnboardingService.resetOnboarding();
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const SplashScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                    ],
                  ),
        ],
      ),
              
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Today's Sales Card
              _TodaySalesCard(),
              
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Quick Stats
        Row(
          children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Today\'s Orders',
                      value: (() {
                        try {
                          final orders = OrdersScope.of(context).orders;
                          final now = DateTime.now();
                          final start = DateTime(now.year, now.month, now.day);
                          final countToday = orders.where((o) => o.createdAt.isAfter(start)).length;
                          return countToday.toString();
                        } catch (_) {
                          return '-';
                        }
                      })(),
                      icon: Icons.receipt_long,
                      color: AppColors.primaryCta,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Revenue',
                      value: (() {
                        try {
                          final orders = OrdersScope.of(context).orders;
                          final now = DateTime.now();
                          final start = DateTime(now.year, now.month, now.day);
                          final todayOrders = orders.where((o) => o.createdAt.isAfter(start)).toList();
                          final todaySales = todayOrders.fold(0.0, (sum, o) => sum + o.amount);
                          return '₺${todaySales.toStringAsFixed(0)}';
                        } catch (_) {
                          return '₺0';
                        }
                      })(),
                      icon: Icons.attach_money,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // New Order Button
              _NewOrderButton(),
              
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Unified Section: Top Performers + Quick Actions
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Color(0xFF3A3C51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Performers Section
                    Text(
                      'Top Performers Today',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    const _TopPerformersBackgrounds(),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    // Quick Actions inside the same section
                    const _QuickActions(),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 20 : 24),

              // Recent Orders Section (separate)
              Text(
                'Recent Orders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              const _RecentActivityList(),
              SizedBox(height: isSmallScreen ? 20 : 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySalesCard extends StatelessWidget {
  const _TodaySalesCard();
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;
    
    try {
      final orders = OrdersScope.of(context).orders;
      final now = DateTime.now();
      
      // Calculate today's sales
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayOrders = orders.where((o) => o.createdAt.isAfter(todayStart)).toList();
      final todaySales = todayOrders.fold(0.0, (sum, order) => sum + order.amount);
      
      // Calculate yesterday's sales
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));
      final yesterdayEnd = todayStart;
      final yesterdayOrders = orders.where((o) => 
        o.createdAt.isAfter(yesterdayStart) && o.createdAt.isBefore(yesterdayEnd)).toList();
      final yesterdaySales = yesterdayOrders.fold(0.0, (sum, order) => sum + order.amount);
      
      // Calculate this week's sales
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekOrders = orders.where((o) => o.createdAt.isAfter(weekStartDay)).toList();
      final weekSales = weekOrders.fold(0.0, (sum, order) => sum + order.amount);
      
      // Calculate this month's sales
      final monthStart = DateTime(now.year, now.month, 1);
      final monthOrders = orders.where((o) => o.createdAt.isAfter(monthStart)).toList();
      final monthSales = monthOrders.fold(0.0, (sum, order) => sum + order.amount);
      
      // Calculate difference from yesterday
      final difference = todaySales - yesterdaySales;
      final isPositive = difference >= 0;
    
    return Container(
      width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with trend icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Text(
                  'Today\'s Sales',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isSmallScreen ? 16 : 20),
            
            // Main sales amount
                      Text(
                        '₺${todaySales.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                fontSize: isSmallScreen ? 28 : (isTablet ? 40 : 36),
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 4 : 6),
            
            // Comparison with yesterday
                          Text(
              '${isPositive ? '+' : ''}₺${difference.abs().toStringAsFixed(0)} vs yesterday',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
            
            SizedBox(height: isSmallScreen ? 16 : 20),
            
            // This Week and This Month stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        '₺${weekSales.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Vertical divider
                Container(
                  width: 1,
                  height: isSmallScreen ? 48 : (isTablet ? 58 : 53),
                  margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  color: Colors.grey.withOpacity(0.4),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        '₺${monthSales.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      // Fallback when OrdersScope is not available
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isSmallScreen ? 40 : (isTablet ? 60 : 50),
                color: AppColors.textSecondary,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'Unable to load sales data',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                  fontWeight: FontWeight.w600,
                ),
            ),
          ],
        ),
      ),
    );
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              Icon(
                Icons.trending_up,
                          color: AppColors.textSecondary,
                size: isSmallScreen ? 16 : 20,
                      ),
                    ],
                  ),
          SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  value, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
              fontSize: isSmallScreen ? 20 : (isTablet ? 28 : 24),
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
            title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 14),
                        ),
                      ),
                    ],
      ),
    );
  }
}

class _TopPerformersBackgrounds extends StatelessWidget {
  const _TopPerformersBackgrounds();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;
    
    // Responsive height calculation
    final containerHeight = isSmallScreen ? 200.0 : (isTablet ? 280.0 : 250.0);
    
    try {
      final orders = OrdersScope.of(context).orders;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      // Get today's orders
      final todayOrders = orders.where((o) => o.createdAt.isAfter(todayStart)).toList();
      
      if (todayOrders.isEmpty) {
        // Show no orders illustration
    return Container(
          height: containerHeight,
            decoration: BoxDecoration(
        color: Color(0xFF3A3C51),
              borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(
                  Icons.trending_up_outlined,
                  size: isSmallScreen ? 40 : (isTablet ? 60 : 50),
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                  'No orders today yet',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  'Start taking orders to see top performers',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: isSmallScreen ? 12 : (isTablet ? 14 : 13),
                  ),
                      textAlign: TextAlign.center,
                ),
              ],
                      ),
                    ),
                  );
      }
      
      // Calculate item performance and remember first available imageUrl per item name
      final Map<String, int> itemCounts = {};
      final Map<String, double> itemRevenue = {};
      final Map<String, String> itemImageByName = {};
      
      for (final order in todayOrders) {
        for (final item in order.items) {
          itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity.toInt();
          itemRevenue[item.name] = (itemRevenue[item.name] ?? 0) + (item.price * item.quantity);
          // Capture an imageUrl for this item if provided (prefer first-seen)
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
            itemImageByName.putIfAbsent(item.name, () => item.imageUrl!);
          }
        }
      }
      
      // Sort by quantity sold
      final sortedItems = itemCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      // Take top 3 performers
      final topPerformers = sortedItems.take(3).toList();
      
      if (topPerformers.isEmpty) {
        // Show no items sold illustration
        return Container(
          height: containerHeight,
            decoration: BoxDecoration(
            color: Color(0xFF3A3C51),
              borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
                child: Center(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: isSmallScreen ? 40 : (isTablet ? 60 : 50),
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'No items sold today',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  'Complete some orders to see top performers',
                        style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: isSmallScreen ? 12 : (isTablet ? 14 : 13),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      
      // Show top performers with real data
        return Container(
        height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
              children: [
              // Background image (new_background.png)
              Image.asset(
                'assets/images/dashboard/new_background.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  print('Background image load error: $error');
                  return Container(
                    color: Colors.green,
                    child: const Center(
                      child: Text(
                        'Background Error',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
              // Dynamic top performers using Row layout
              Row(
                children: List.generate(3, (index) {
                  if (index < topPerformers.length) {
                    final performer = topPerformers[index];
                    final itemName = performer.key;
                    final soldCount = performer.value;
                    final ranking = index + 1;
                    
                    // Prefer captured imageUrl from the actual order, fallback to resolver
                    String imagePath = itemImageByName[itemName] ?? _resolveImageForItem(itemName);
                    print('Top Performer ${index + 1}: $itemName -> $imagePath');
                    
                    return Expanded(
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 18),
                      child: Stack(
                        children: [
                          // Frame.png as background
                          Positioned(
                            right: 2,
                            top: 0,
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/dashboard/Frame.png',
                              fit: BoxFit.fill,
                                width: isSmallScreen ? 90 : (isTablet ? 130 : 112),
                                height: isSmallScreen ? 90 : (isTablet ? 130 : 112),
                            errorBuilder: (context, error, stackTrace) {
                                  print('Frame ${index + 1} load error: $error');
                              return Container(
                                color: Colors.red.withOpacity(0.5),
                                    child: Center(
                                  child: Text(
                                        'Frame ${index + 1} Error',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                            ),
                          ),
                            // Content positioned to fit inside Frame.png
                            Positioned(
                              left: isSmallScreen ? 8 : 12,
                              top: isSmallScreen ? 8 : 12,
                              right: isSmallScreen ? 8 : 12,
                              bottom: isSmallScreen ? 8 : 12,
                            child: Column(
                              children: [
                                  // Dish photo at the top
                                Transform.translate(
                                  offset: Offset(-4.5, 0),
                                  child: Container(
                                    width: isSmallScreen ? 70 : (isTablet ? 100 : 90),
                                    height: isSmallScreen ? 70 : (isTablet ? 100 : 90),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(isSmallScreen ? 35 : (isTablet ? 50 : 45)),
                                        topRight: Radius.circular(isSmallScreen ? 35 : (isTablet ? 50 : 45)),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(isSmallScreen ? 35 : (isTablet ? 50 : 45)),
                                        topRight: Radius.circular(isSmallScreen ? 35 : (isTablet ? 50 : 45)),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0),
                                      ),
                                    child: Image.asset(
                                        imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                          print('Image load error for $itemName: $imagePath - $error');
                                        return Container(
                                          color: Colors.grey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                                const Icon(Icons.fastfood, color: Colors.white),
                                                const SizedBox(height: 4),
                                                Text(
                                                  itemName,
                                                  style: const TextStyle(
                                    color: Colors.white,
                                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  // Content at the bottom - positioned inside frame
                  Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                        // Dish name - responsive sizing to fit frame
                                        Flexible(
                                          child: Text(
                                            _truncateItemName(itemName),
                                  style: TextStyle(
                                    color: Colors.white,
                                              fontSize: isSmallScreen ? 8 : (isTablet ? 12 : 10),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 4 : 6),
                                // Ranking
                                        Text(
                                          '#$ranking',
                                  style: TextStyle(
                                    color: Colors.white,
                                            fontSize: isSmallScreen ? 14 : (isTablet ? 20 : 18),
                                            fontWeight: FontWeight.w900,
                                            fontStyle: FontStyle.italic,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                                        SizedBox(height: isSmallScreen ? 4 : 6),
                                // Sold quantity
                                        Text(
                                          '$soldCount Sold',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                            fontSize: isSmallScreen ? 11 : (isTablet ? 15 : 13),
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    ),
              ),
            ],
          ),
        ),
      );
                  } else {
                    // Empty slot if less than 3 performers
                    return Expanded(
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 18),
        decoration: BoxDecoration(
                          color: AppColors.cardSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withOpacity(0.2)),
                        ),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              // Different icons based on ranking position
                              Icon(
                                index == 1 ? Icons.trending_up : Icons.schedule,
                                size: isSmallScreen ? 30 : (isTablet ? 40 : 35),
                                color: AppColors.textSecondary.withOpacity(0.6),
                              ),
                              SizedBox(height: isSmallScreen ? 4 : 6),
                              Text(
                                index == 1 ? 'Rank #2' : 'Rank #3',
                                  style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.6),
                                  fontSize: isSmallScreen ? 10 : (isTablet ? 12 : 11),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                index == 1 ? 'Waiting...' : 'Coming Soon',
                                  style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(0.4),
                                  fontSize: isSmallScreen ? 8 : (isTablet ? 10 : 9),
                                  ),
                                ),
                              ],
                            ),
                                  ),
                                ),
                              );
                  }
                }),
                          ),
                        ],
                      ),
                    ),
      );
    } catch (e) {
      // Fallback when OrdersScope is not available
      print('OrdersScope error: $e');
                              return Container(
        height: containerHeight,
                      decoration: BoxDecoration(
          color: Color(0xFF3A3C51),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
                      ),
        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
              Icon(
                Icons.error_outline,
                size: isSmallScreen ? 40 : (isTablet ? 60 : 50),
                color: AppColors.textSecondary,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                'Unable to load top performers',
                                  style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                'OrdersScope not available: ${e.toString()}',
                                  style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: isSmallScreen ? 10 : (isTablet ? 12 : 11),
                                  ),
                                  textAlign: TextAlign.center,
              ),
            ],
        ),
      ),
    );
  }
  }

  // Deterministic resolver: normalize item name and map by exact/keyword rules
  String _resolveImageForItem(String rawName) {
    if (rawName.isEmpty) {
      print('DEBUG: Empty item name, using default image');
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg';
    }
    // Remove add-ons/size notes like " + Extra Cheese" or texts in brackets
    final baseName = rawName
        .split('+')
        .first
        .replaceAll(RegExp(r'\s*[\[(].*?[\])]\s*'), '')
        .trim();

    final normalized = baseName
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    print('DEBUG: Resolving image for "$rawName" -> base: "$baseName" -> normalized: "$normalized"');

    // Exact matches first (normalized keys) - Updated for P151 menu
    final Map<String, String> exact = {
      // Burgers
      'only burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg',
      'truf burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBurger.jpg',
      'sympaty burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyBurger.jpg',
      'hot burger': 'assets/images/P151/P151_Menu_Images_Size Reduced/HotBurger.jpg',
      
      // Brioche
      'only brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBrioche.jpg',
      'truf brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBrioche.jpg',
      'ceasar brioche': 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarBrioche.jpg',
      
      // Wings
      '5li wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/5liWings.jpg',
      '7li wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/7liWings.jpg',
      '9li wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/9liWings.jpg',
      '5 wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/5liWings.jpg',
      '7 wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/7liWings.jpg',
      '9 wings': 'assets/images/P151/P151_Menu_Images_Size Reduced/9liWings.jpg',
      
      // Ortaya Karışık
      'citir tavuk': 'assets/images/P151/P151_Menu_Images_Size Reduced/trTavuk.jpg',
      'patates tava': 'assets/images/P151/P151_Menu_Images_Size Reduced/PatatesTava.jpg',
      'truflu parmesanli patates': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrflParmesanlPatates.jpg',
      'tapas cheddarlı patates': 'assets/images/P151/P151_Menu_Images_Size Reduced/TapasCheddarlPatates.jpg',
      'only cheese': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheese.jpg',
      'hallumi': 'assets/images/P151/P151_Menu_Images_Size Reduced/Hallumi.jpg',
      
      // Bowls & Coleslaw
      'grill chicken bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/GrillChickenBowl.jpg',
      'popchicken bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenBowl.jpg',
      'teriyaki bowl': 'assets/images/P151/P151_Menu_Images_Size Reduced/TeriyakiBowl.jpg',
      'popchicken ceasar salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenCeasarSalat.jpg',
      'chicken ceasar salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/ChickenCeasarSalat.jpg',
      'only cheese salat': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheeseSalat.jpg',
      
      // Wrap
      'only wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyWrap.jpg',
      'truf wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfWrap.jpg',
      'ceasar wrap': 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarWrap.jpg',
      
      // Tenders
      '3lu tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/3lTenders.jpg',
      '5li tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/5lTenders.jpg',
      '7li tenders': 'assets/images/P151/P151_Menu_Images_Size Reduced/7lTenders.jpg',
      '3 tenders': 'assets/images/P151/P151_Menu_Images/tenders_3lu.jpg',
      '5 tenders': 'assets/images/P151/P151_Menu_Images/tenders_5li.jpg',
      '7 tenders': 'assets/images/P151/P151_Menu_Images/tenders_7li.jpg',
      
      // Combos
      'only summer combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlySummerComb.jpeg',
      'hot combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/HotCombo.jpg',
      'sympaty combo': 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyCombo.jpg',
    };
    if (exact.containsKey(normalized)) {
      print('DEBUG: Exact match found for "$normalized" -> ${exact[normalized]}');
      return exact[normalized]!;
    }

    // New: try matching by the last two words (e.g., "chicken sandwich")
    final parts = normalized.split(' ');
    if (parts.length >= 2) {
      final lastTwo = '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
      if (exact.containsKey(lastTwo)) {
        print('DEBUG: Last-two-words match for "$lastTwo" -> ${exact[lastTwo]}');
        return exact[lastTwo]!;
      }
    }

    // Keyword heuristics for P151 menu items
    bool has(String s) => normalized.contains(s);
    
    if (has('burger')) {
      if (has('hot')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/HotBurger.jpg';
      if (has('truf') || has('truffle')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBurger.jpg';
      if (has('sympaty')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyBurger.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg';
    }
    
    if (has('brioche')) {
      if (has('ceasar')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarBrioche.jpg';
      if (has('truf') || has('truffle')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfBrioche.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBrioche.jpg';
    }
    
    if (has('wings')) {
      if (has('9') || has('nine')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/9liWings.jpg';
      if (has('7') || has('seven')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/7liWings.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/5liWings.jpg';
    }
    
    if (has('bowl')) {
      if (has('teriyaki')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TeriyakiBowl.jpg';
      if (has('popchicken')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenBowl.jpg';
      if (has('grill')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/GrillChickenBowl.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/GrillChickenBowl.jpg';
    }
    
    if (has('salat') || has('salad')) {
      if (has('popchicken') && has('ceasar')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/PopChickenCeasarSalat.jpg';
      if (has('ceasar') || has('caesar')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/ChickenCeasarSalat.jpg';
      if (has('cheese')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheeseSalat.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/ChickenCeasarSalat.jpg';
    }
    
    if (has('wrap')) {
      if (has('ceasar') || has('caesar')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/CeasarWrap.jpg';
      if (has('truf') || has('truffle')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TrfWrap.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyWrap.jpg';
    }
    
    if (has('tender')) {
      if (has('7') || has('seven')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/7lTenders.jpg';
      if (has('5') || has('five')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/5lTenders.jpg';
      if (has('3') || has('three') || has('lu')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/3lTenders.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/5lTenders.jpg';
    }
    
    if (has('combo')) {
      if (has('hot')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/HotCombo.jpg';
      if (has('sympaty')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/SympatyCombo.jpg';
      if (has('summer')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlySummerComb.jpeg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlySummerComb.jpeg';
    }
    
    if (has('tavuk') || has('chicken')) {
      if (has('citir') || has('citir')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/trTavuk.jpg';
    }
    
    if (has('patates') || has('potato')) {
      if (has('truflu') || has('parmesan')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TrflParmesanlPatates.jpg';
      if (has('tapas') || has('cheddar')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/TapasCheddarlPatates.jpg';
      if (has('tava')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/PatatesTava.jpg';
    }
    
    if (has('cheese')) {
      if (has('salat') || has('salad')) return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheeseSalat.jpg';
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyCheese.jpg';
    }
    
    if (has('hallumi')) {
      return 'assets/images/P151/P151_Menu_Images_Size Reduced/Hallumi.jpg';
    }

    // Default fallback
    print('DEBUG: No match found for "$normalized", using default OnlyBurger.jpg');
    return 'assets/images/P151/P151_Menu_Images_Size Reduced/OnlyBurger.jpg';
  }
  
  // Helper function to truncate long item names to show only last 2 words
  String _truncateItemName(String itemName) {
    final words = itemName.split(' ');
    if (words.length <= 2) {
      return itemName; // Return as is if 2 words or less
    }
    // Return only the last 2 words
    return '${words[words.length - 2]} ${words[words.length - 1]}';
  }
}

// Quick Actions section below Top Performers
class _QuickActions extends StatefulWidget {
  const _QuickActions();

  @override
  State<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<_QuickActions> {
  int _staffCount = 0;
  int _inventoryCount = 0;
  int _menuCount = 0;
  bool _isLoading = true;
  final StaffRepository _staffRepository = StaffRepository();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final staff = await _staffRepository.getAllStaff();
      final inventory = await _inventoryRepository.getAllItems();
      final MenuRepository menuRepository = CsvMenuRepository();
      final menuItems = await menuRepository.getMenuItems();
      
      if (mounted) {
        setState(() {
          _staffCount = staff.length;
          _inventoryCount = inventory.length;
          _menuCount = menuItems.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header pill as full-width button
        Material(
            color: Color(0xFF4E4F61),
            borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 14 : 16,
                vertical: isSmallScreen ? 10 : 12,
              ),
        decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  const Icon(Icons.restaurant_menu_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: isSmallScreen ? 8 : 10),
                  Text(
                    'View Menu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
                  ),
                ),
              ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Stat chips row (Staff, Menu, Inventory, Tables)
        Row(
          children: [
            Expanded(
              child: _StatPill(
                label: _isLoading ? '-' : _staffCount.toString().padLeft(2, '0'),
                sublabel: 'STAFF',
                onTap: null,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: _StatPill(
                label: _isLoading ? '-' : _menuCount.toString().padLeft(2, '0'),
                sublabel: 'MENU',
                onTap: null,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: _StatPill(
                label: _isLoading ? '-' : _inventoryCount.toString().padLeft(2, '0'),
                sublabel: 'INVENTORY',
                onTap: null,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: _StatPill(
                label: (() {
                  try {
                    final orders = OrdersScope.of(context).orders;
                    final now = DateTime.now();
                    final start = DateTime(now.year, now.month, now.day);
                    final countToday = orders.where((o) => o.createdAt.isAfter(start)).length;
                    return countToday.toString().padLeft(2, '0');
                  } catch (_) {
                    return '-';
                  }
                })(),
                sublabel: 'ORDERS',
                onTap: null,
              ),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Big action buttons
        Row(
          children: [
                                    Expanded(
              child: _ActionBlock(
                color: const Color(0xFFF3B338), // yellow
                icon: Icons.add,
                title: 'ADD NEW',
                subtitle: 'INVENTORY',
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  );
                  // Reload data if item was added
                  if (result != null && mounted) {
                    _loadData();
                  }
                },
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
                                    Expanded(
              child: _ActionBlock(
                color: const Color(0xFF2ECC71), // green
                icon: Icons.add,
                title: 'ADD NEW',
                subtitle: 'STAFF',
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddStaffScreen(),
                    ),
                  );
                  // Reload data if staff was added
                  if (result != null && mounted) {
                    _loadData();
                  }
                },
              ),
            ),
          ],
        ),

        // Recent Activity will be rendered outside of _QuickActions by parent
      ],
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 600;

    try {
      final orders = OrdersScope.of(context).orders;
      
      // Sort by most recent and take top 5
      final recentOrders = orders.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final top5Orders = recentOrders.take(5).toList();

      if (top5Orders.isEmpty) {
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: isSmallScreen ? 40 : 50,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'No recent orders',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: top5Orders.map((order) {
          return _RecentActivityRow(
            order: order,
            isSmallScreen: isSmallScreen,
          );
        }).toList(),
      );
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            'Unable to load recent activity',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      );
    }
  }
}

class _RecentActivityRow extends StatelessWidget {
  final dynamic order;
  final bool isSmallScreen;

  const _RecentActivityRow({
    required this.order,
    required this.isSmallScreen,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getOrderTypeLabel() {
    if (order.type == 'dine_in' && order.tableNumber != null) {
      return 'Table ${order.tableNumber}';
    }
    return order.type == 'dine_in' ? 'Dine In' : 'Takeaway';
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = order.itemCount ?? order.items.length;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Order icon/thumbnail
          Container(
            width: isSmallScreen ? 48 : 56,
            height: isSmallScreen ? 48 : 56,
            decoration: BoxDecoration(
              color: AppColors.primaryCta.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: order.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      order.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.receipt_long,
                          color: AppColors.primaryCta,
                          size: isSmallScreen ? 24 : 28,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryCta,
                    size: isSmallScreen ? 24 : 28,
                  ),
          ),
          
          SizedBox(width: isSmallScreen ? 12 : 16),
          
          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getOrderTypeLabel(),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₺${order.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: isSmallScreen ? 14 : 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Icon(
                      Icons.access_time,
                      size: isSmallScreen ? 14 : 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatTime(order.createdAt),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  const _StatPill({required this.label, required this.sublabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallStat = screenHeight < 600;
    return Material(
          color: Color(0xFF4E4F61),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: BoxConstraints(minHeight: isSmallStat ? 56 : 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallStat ? 22 : 18,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.7,
                  fontSize: isSmallStat ? 9 : 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
            ),
          ),
        ),
      );
    }
  }

class _ActionBlock extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionBlock({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 96,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.add, color: Colors.black, size: 22),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewOrderButton extends StatelessWidget {
  const _NewOrderButton();
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;

    return Container(
      width: double.infinity,
      height: isSmallScreen ? 56 : (isTablet ? 64 : 60),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _navigateToBilling(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
          ),
        ),
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
              padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                Icons.add_shopping_cart,
                size: isSmallScreen ? 20 : (isTablet ? 24 : 22),
                color: Colors.white,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
                      Text(
              'New Order',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : (isTablet ? 20 : 18),
                      fontWeight: FontWeight.bold,
                color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
    );
  }
  
  void _navigateToBilling(BuildContext context) {
    _navigateToBillingAsync(context);
  }

  Future<void> _navigateToBillingAsync(BuildContext context) async {
    // Prevent placing orders if there are no staff members
    try {
      final staffRepo = StaffRepository();
      final staffList = await staffRepo.getAllStaff();
      if (staffList.isEmpty) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add Staff Required'),
              content: const Text('Please add at least one staff member before placing an order.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (_) {
      // If staff read fails, allow flow to continue rather than blocking unexpectedly
    }

    // Clear any existing cart items for a fresh new order
    final cart = AppControllers.cartController;
    cart.clear(); // Start with empty cart for new order

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CartScope(
          controller: AppControllers.cartController,
          child: const BillingScreen(),
        ),
      ),
    );
  }
}