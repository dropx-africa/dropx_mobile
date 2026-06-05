import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          'Terms of Use',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entity header
            _buildCard(children: [
              const AppText(
                'PROWHEELS INTEGRATED SERVICES LIMITED',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBackground,
              ),
              const SizedBox(height: 4),
              _bodyText('Trading as DropX · RC No. RC 766713'),
              _bodyText('2 Ijesha Close, Off Obokun Street, Ilupeju, Lagos State'),
              const SizedBox(height: 8),
              _bodyText('Contact: hello@dropx.africa · support@dropx.africa'),
              const SizedBox(height: 4),
              _bodyText('DropX is a registered trademark of Prowheels Integrated Services Limited.'),
            ]),
            const SizedBox(height: 20),

            _sectionHeader('1. Acceptance'),
            _buildCard(children: [
              _bodyText(
                'These Customer Terms of Use govern your access to and use of the DropX '
                'platform, including the DropX customer application, website, wallet credit, '
                'marketplace ordering, parcel delivery, payment links, support channels, and '
                'related services.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'By creating an account, placing an order, requesting a parcel delivery, '
                'funding wallet credit, using a payment link, or otherwise using DropX, you '
                'agree to these terms and all incorporated policies.',
              ),
              const SizedBox(height: 10),
              _bodyText('If you do not agree, you must not use DropX.'),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('2. Incorporated Documents'),
            _buildCard(children: [
              _bodyText('These terms incorporate the following documents:'),
              const SizedBox(height: 8),
              _bullet('Refund, Cancellation, Returns and Dispute Policy.'),
              _bullet('Wallet and Platform Credit Terms.'),
              _bullet('Parcel Delivery and Liability Terms.'),
              _bullet('Prohibited Items and Acceptable Use Policy.'),
              _bullet('Privacy Notice.'),
              _bullet('Cookie Notice.'),
              const SizedBox(height: 4),
              _bodyText(
                'If there is a conflict, a signed or service-specific schedule controls for '
                'that service, followed by these terms and then incorporated policies.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('3. DropX Role'),
            _buildCard(children: [
              _bodyText('Depending on the service, DropX may:'),
              const SizedBox(height: 8),
              _bullet('Connect customers with approved merchants.'),
              _bullet('Facilitate order placement, payment collection, customer support, and delivery coordination.'),
              _bullet('Coordinate parcel delivery through independent riders, logistics partners, or managed dispatch resources.'),
              _bullet('Provide wallet credit usable only on DropX.'),
              const SizedBox(height: 8),
              _bodyText(
                'For marketplace goods, the merchant remains responsible for product quality, '
                'lawful sale, food safety, stock availability, descriptions, pricing accuracy, '
                'ingredients, allergen information, packaging, licences, and taxes. DropX may '
                'support customers and investigate issues but is not the manufacturer, '
                'restaurant, grocer, retailer, or product owner unless expressly stated in writing.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('4. Account Eligibility'),
            _buildCard(children: [
              _bodyText(
                'You must be at least 18 years old and able to enter legally binding contracts '
                'to use DropX. You must provide accurate account information and keep your '
                'phone number, email address, delivery address, payment method, and other '
                'account details up to date.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'You are responsible for activity under your account unless caused solely by '
                'DropX\'s proven security failure. You must promptly notify DropX of suspected '
                'unauthorised access.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('5. Service Availability'),
            _buildCard(children: [
              _bodyText(
                'DropX services are available only in approved service zones, delivery times, '
                'merchant availability windows, rider availability windows, and operational '
                'conditions. Launch availability is expected to focus on selected Lagos areas, '
                'including Ikeja, Yaba, and Surulere corridors, but coverage may change.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'DropX may refuse, cancel, delay, or reroute orders where required for safety, '
                'fraud prevention, regulatory compliance, service capacity, weather, traffic, '
                'rider availability, merchant availability, payment issues, prohibited items, '
                'or force majeure.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('6. Marketplace Orders'),
            _buildCard(children: [
              _bodyText('When you place a food, grocery, or retail order:'),
              const SizedBox(height: 8),
              _bullet('You authorise DropX to transmit your order to the merchant.'),
              _bullet('You agree to pay item prices, delivery fees, service fees, payment processing charges, taxes, wallet charges, and any applicable charges shown before checkout.'),
              _bullet('The merchant may accept, reject, or cancel an order if stock, pricing, operational, compliance, or safety issues arise.'),
              _bullet('Product images may be illustrative and may differ from actual products.'),
              _bullet('Substitutions, unavailable items, and merchant-caused errors are handled under the Refund, Cancellation, Returns and Dispute Policy.'),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('7. Parcel Delivery'),
            _buildCard(children: [
              _bodyText(
                'Parcel delivery is subject to the Parcel Delivery and Liability Terms and '
                'the Prohibited Items and Acceptable Use Policy.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'The standard parcel liability cap is ₦10,000 unless a signed commercial '
                'schedule or activated declared-value protection states otherwise.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('8. Pharmacy and Medical Exclusion'),
            _buildCard(children: [
              _bodyText(
                'Pharmacy services are excluded at launch. You must not use DropX to order, '
                'sell, request, deliver, or send:',
              ),
              const SizedBox(height: 8),
              _bullet('Prescription medicines.'),
              _bullet('Over-the-counter medicines.'),
              _bullet('Regulated medical products.'),
              _bullet('Medical samples, controlled substances, or pharmaceuticals.'),
              _bullet('Temperature-controlled medical or cold-chain items.'),
              _bullet('Any item requiring pharmacy, medical, health, or controlled-drug licensing.'),
              const SizedBox(height: 8),
              _bodyText(
                'DropX may cancel, refuse, suspend, report, or dispose of any order or parcel '
                'that appears to breach this exclusion, subject to law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('9. Payments'),
            _buildCard(children: [
              _bodyText(
                'DropX may use third-party payment processors, including payment links, card '
                'payments, bank transfers, USSD, and wallet credit. DropX does not operate as '
                'a bank, deposit-taking institution, escrow provider, or licensed payment '
                'service provider unless expressly stated by a regulator-approved arrangement.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Payment failures, reversals, chargebacks, suspected fraud, processor '
                'downtime, or settlement issues may result in cancellation, suspension, '
                'withholding of delivery, wallet adjustment, or account review.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('10. Wallet Credit'),
            _buildCard(children: [
              _bodyText(
                'Wallet balances are platform credit only. They are not cash, deposits, bank '
                'balances, stored-value accounts, escrow balances, or interest-bearing funds.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Wallet credit may be used only for eligible DropX services and cannot be '
                'withdrawn to a bank account unless DropX is required by law or expressly '
                'approves a correction for an erroneous payment.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('11. Cancellations, Refunds, Returns and Disputes'),
            _buildCard(children: [
              _bodyText(
                'Cancellation and refund rights are governed by the Refund, Cancellation, '
                'Returns and Dispute Policy.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Customer cancellation may be available within 15 minutes of order creation '
                'and only before operational milestones such as preparation, pickup readiness, '
                'dispatch, or in-transit status. DropX may update this timing by policy notice.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Delivered-order disputes should be raised promptly within 72 hours for '
                'eligible issues, subject to the policy and evidence requirements.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('12. User Conduct'),
            _buildCard(children: [
              _bodyText('You must not:'),
              const SizedBox(height: 8),
              _bullet('Use DropX for illegal, unsafe, fraudulent, abusive, or misleading purposes.'),
              _bullet('Send or request prohibited items.'),
              _bullet('Harass, threaten, abuse, discriminate against, or endanger merchants, riders, support staff, recipients, or other users.'),
              _bullet('Circumvent DropX fees, payments, or safety processes.'),
              _bullet('Provide false addresses, false contact details, false parcel descriptions, or false claims.'),
              _bullet('Interfere with platform security, reverse engineer the platform, scrape data, or misuse APIs.'),
              _bullet('Use another person\'s account or payment method without authorisation.'),
              const SizedBox(height: 8),
              _bodyText(
                'DropX may investigate, restrict, suspend, deactivate, reverse wallet credit, '
                'cancel orders, withhold support outcomes, or refer matters to authorities '
                'where necessary.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('13. Delivery, Failed Delivery and Proof'),
            _buildCard(children: [
              _bodyText(
                'DropX may rely on app data, GPS, timestamped rider updates, merchant '
                'acceptance records, OTP/PIN confirmation, signatures, photographs, recipient '
                'confirmation, support tickets, call logs, wallet ledger entries, and payment '
                'processor records as operational evidence.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'If delivery fails because the address is wrong, the recipient is unavailable, '
                'the recipient refuses delivery, access is unsafe, contact details are incorrect, '
                'or the item is prohibited, additional fees may apply and refunds may be denied '
                'or reduced.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('14. Promotions and Credits'),
            _buildCard(children: [
              _bodyText(
                'Promotional credits, vouchers, referrals, discounts, and wallet bonuses are '
                'subject to specific campaign terms. They may be non-transferable, '
                'non-refundable, limited by time, limited by user, and revocable for fraud, '
                'abuse, error, or policy breach.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('15. Intellectual Property'),
            _buildCard(children: [
              _bodyText(
                'The DropX platform, name, logo, designs, software, content, trademarks, '
                'service marks, workflows, data models, operational dashboards, and related '
                'materials are owned by or licensed to DropX.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'You may not copy, modify, reverse engineer, misuse, register, imitate, or '
                'commercially exploit DropX intellectual property without prior written consent.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('16. Data Protection'),
            _buildCard(children: [
              _bodyText(
                'DropX processes personal data in accordance with its Privacy Notice and '
                'applicable data protection law. By using DropX, you acknowledge that DropX '
                'may process customer, sender, recipient, merchant, rider, location, device, '
                'payment, support, and delivery data for platform operation, safety, support, '
                'fraud prevention, legal compliance, and service improvement.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('17. Third-Party Services'),
            _buildCard(children: [
              _bodyText(
                'DropX may rely on merchants, riders, logistics partners, payment processors, '
                'cloud providers, identity verification providers, map providers, messaging '
                'providers, and other third parties.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'DropX is not responsible for third-party failures except where required by '
                'law or expressly stated in a signed agreement. DropX will use reasonable '
                'efforts to coordinate support and resolve customer-impacting issues.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('18. Limitation of Liability'),
            _buildCard(children: [
              _bodyText(
                'To the maximum extent permitted by law, DropX will not be liable for '
                'indirect, incidental, special, punitive, exemplary, or consequential losses, '
                'including loss of profit, business interruption, emotional distress, resale '
                'loss, reputational loss, or data loss.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'For parcel claims, DropX\'s liability is governed by the Parcel Delivery and '
                'Liability Terms. For wallet credit, DropX\'s liability is limited to correcting '
                'eligible ledger errors or restoring eligible platform credit proven to be '
                'wrongfully deducted, subject to fraud review.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Nothing in these terms excludes liability that cannot be excluded under '
                'applicable law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('19. Indemnity'),
            _buildCard(children: [
              _bodyText(
                'You agree to indemnify DropX against losses, claims, penalties, costs, '
                'damages, and expenses arising from your breach of these terms, misuse of the '
                'platform, false information, prohibited items, fraudulent claims, unlawful '
                'conduct, infringement of third-party rights, or harm caused to merchants, '
                'riders, recipients, DropX personnel, or third parties.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('20. Suspension and Termination'),
            _buildCard(children: [
              _bodyText(
                'DropX may suspend, restrict, or terminate your access where it reasonably '
                'suspects fraud, safety risk, payment failure, prohibited item activity, abuse, '
                'unlawful conduct, repeated disputes, chargeback abuse, data misuse, or breach '
                'of these terms.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Where feasible, DropX may provide notice and an opportunity to respond. '
                'Immediate action may be taken where necessary for safety, legal compliance, '
                'fraud prevention, platform integrity, or user protection.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('21. Changes to Terms'),
            _buildCard(children: [
              _bodyText(
                'DropX may update these terms and incorporated policies by app notice, website '
                'notice, email, or other reasonable method. Continued use after notice means '
                'you accept the updated terms, subject to applicable law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('22. Governing Law and Dispute Resolution'),
            _buildCard(children: [
              _bodyText(
                'These terms are governed by the laws of the Federal Republic of Nigeria.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Before arbitration, the parties will attempt good-faith resolution through '
                'support escalation or written negotiation for 30 days.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Any dispute not resolved within that period will be referred to arbitration '
                'administered by the Lagos Court of Arbitration. The seat and venue will be '
                'Lagos, Nigeria. The tribunal will consist of one arbitrator. The language will '
                'be English. The award will be final and binding.',
              ),
              const SizedBox(height: 10),
              _bodyText(
                'Nothing prevents a party from seeking urgent court relief for fraud, '
                'intellectual property misuse, data breach, confidentiality breach, unpaid '
                'sums, safety issues, prohibited goods, account abuse, or platform security '
                'threats.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('23. Notices'),
            _buildCard(children: [
              _bodyText(
                'Notices to DropX may be sent to hello@dropx.africa or support@dropx.africa, '
                'or to the head office listed above. DropX may send notices through the app, '
                'website, email, SMS, WhatsApp, push notification, or other contact details '
                'associated with your account.',
              ),
            ]),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: AppText(
                'PROWHEELS INTEGRATED SERVICES LIMITED · DropX Africa',
                fontSize: 11,
                color: AppColors.slate400,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: AppText(
          title.toUpperCase(),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: AppColors.slate500,
        ),
      );

  Widget _buildCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _bodyText(String text) => AppText(
        text,
        fontSize: 14,
        color: AppColors.slate500,
        height: 1.55,
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('• ', fontSize: 14, color: AppColors.primaryOrange),
            Expanded(
              child: AppText(
                text,
                fontSize: 14,
                color: AppColors.slate500,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
}
