import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/in_app_purchase_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  InAppPurchaseProvider? _listenerProvider;
  Timer? _purchaseTimeout;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    // Attach a listener so we react when premium is actually activated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InAppPurchaseProvider>();
      _listenerProvider = provider;
      provider.addListener(_onPurchaseProviderChanged);
    });
  }

  Future<void> _initializeIAP() async {
    final purchaseProvider = context.read<InAppPurchaseProvider>();
    // Setup is already done in constructor, but we can call it again if needed
    await purchaseProvider.setupStoreData();
  }

  Future<void> _handlePurchase() async {
    try {
      final purchaseProvider = context.read<InAppPurchaseProvider>();

      // Pre-checks: avoid stuck flows if store isn't ready
      if (!purchaseProvider.serviceActive) {
        _showMessage('Store unavailable. Please check your network or try later.');
        return;
      }
      if (purchaseProvider.products.isEmpty) {
        await purchaseProvider.setupStoreData();
        if (purchaseProvider.products.isEmpty) {
          _showMessage('Purchase options not available. Try Restore or later.');
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });
      // THIS IS THE METHOD YOUR SENIOR MENTIONED!
      await purchaseProvider.buyNONConsumableInAppPurchase();

      // Fallback timeout: stop spinner if nothing completes within 20s
      _purchaseTimeout?.cancel();
      _purchaseTimeout = Timer(const Duration(seconds: 20), () {
        if (!mounted) return;
        final provider = context.read<InAppPurchaseProvider>();
        if (_isLoading && !provider.isPremiumMember) {
          setState(() {
            _isLoading = false;
          });
          _showMessage('Purchase taking longer than expected. If charged, tap Restore.');
        }
      });
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final purchaseProvider = context.read<InAppPurchaseProvider>();
      // THIS IS THE RESTORE METHOD YOUR SENIOR MENTIONED!
      await purchaseProvider.restorePurchases();
      _showMessage('Restore completed. Check your subscription status.');
    } catch (e) {
      _showMessage('Error restoring purchases: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<InAppPurchaseProvider>();
    
    // Debug print to check premium status
    debugPrint('Premium Screen - isPremiumMember: ${purchaseProvider.isPremiumMember}');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildUpgradeView(purchaseProvider),
    );
  }

  void _onPurchaseProviderChanged() {
    final provider = _listenerProvider;
    if (!mounted || provider == null) return;
    if (provider.isPremiumMember) {
      // Purchase completed – stop loading and show success once
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
      _showMessage('🎉 Premium activated! Enjoy ad-free experience!');
      _purchaseTimeout?.cancel();
      _purchaseTimeout = null;
      return;
    }

    // If provider reported an error, stop loading
    if (provider.errorInfo != null && _isLoading) {
      setState(() {
        _isLoading = false;
      });
      _purchaseTimeout?.cancel();
      _purchaseTimeout = null;
      _showMessage('Purchase failed: ${provider.errorInfo}');
    }
  }

  Widget _buildUpgradeView(InAppPurchaseProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                
                const Text(
                  'Remove Ads',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeaturesCard(),

                const SizedBox(height: 32),

                _buildPurchaseCard(provider),

                const SizedBox(height: 20),

                Column(
                  children: [
                    // Show different content based on premium status
                    if (provider.isPremiumMember) ...[
                      // Premium User - Show success message instead of button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF4CAF50),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Premium Active!',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You\'re enjoying ad-free experience',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Free User - Show upgrade button (matching reference green)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handlePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upgrade Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Restore Button (styled as proper button)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleRestore,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text(
                          'Restore Purchase',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listenerProvider?.removeListener(_onPurchaseProviderChanged);
    _purchaseTimeout?.cancel();
    super.dispose();
  }

  Widget _buildHeroSection() {
    return Container(
      height: 350,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/images/onboarding/onboarding3.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2D1B69),
                          Color(0xFF11998E),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Premium Experience\nUnlock Ad-Free',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A1A1A).withOpacity(0.8),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: const Text(
              'Get Premium',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 6,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildFeatureRow(
            'Upgrade to an ad-free app for uninterrupted flow.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseCard(InAppPurchaseProvider provider) {
    final products = provider.products;
    final price = products.isNotEmpty ? products.first.price : '\$0.99'; // Fallback to $0.99 if product not loaded
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFFA726), // Orange
            Color(0xFFEC407A), // Pink
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA726).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'One Time Purchase',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
