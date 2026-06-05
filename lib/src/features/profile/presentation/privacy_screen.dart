import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          'Privacy Notice',
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
            ]),
            const SizedBox(height: 20),

            _sectionHeader('1. Purpose'),
            _buildCard(children: [
              _bodyText(
                'This Privacy Notice explains how DropX collects, uses, stores, '
                'shares, and protects personal data relating to customers, merchants, '
                'riders, parcel senders, recipients, business users, support contacts, '
                'website visitors, job applicants, vendors, and other users of the '
                'DropX ecosystem.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('2. Data Controller'),
            _buildCard(children: [
              _bodyText(
                'The data controller is PROWHEELS INTEGRATED SERVICES LIMITED, '
                'trading as DropX.',
              ),
              const SizedBox(height: 8),
              _bodyText(
                'Data protection contact: hello@dropx.africa or support@dropx.africa.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('3. Personal Data We Process'),
            _buildCard(children: [
              _bullet('Identity data: name, username, business name, government ID where required, KYC records.'),
              _bullet('Contact data: phone number, email address, delivery address, pickup address, recipient details.'),
              _bullet('Account data: login details, role, permissions, profile settings, preferences.'),
              _bullet('Order data: items ordered, merchant, basket, substitutions, delivery instructions, cancellations, refunds, disputes.'),
              _bullet('Parcel data: sender, recipient, declared contents, declared value, pickup/drop-off information, proof of delivery.'),
              _bullet('Payment data: payment references, wallet ledger entries, transaction metadata, PSP confirmation records.'),
              _bullet('Location data: delivery location, pickup location, rider location during active delivery, route and distance data.'),
              _bullet('Device and technical data: IP address, device type, app version, identifiers, logs, crash data, analytics data.'),
              _bullet('Communication data: support tickets, chat, email, SMS, feedback, ratings.'),
              _bullet('Merchant and rider compliance data: licences, vehicle details, insurance evidence, onboarding status, payout details.'),
              _bullet('Safety and fraud data: suspicious activity indicators, chargebacks, incident reports, internal investigation notes.'),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('4. Lawful Bases and Purposes'),
            _buildCard(children: [
              _purposeRow('Account creation and authentication', 'Contract performance, legitimate interest, consent where required.'),
              _divider(),
              _purposeRow('Order and parcel fulfilment', 'Contract performance and legitimate interest.'),
              _divider(),
              _purposeRow('Payment processing and wallet ledger', 'Contract performance, legal obligation, legitimate interest.'),
              _divider(),
              _purposeRow('Customer support and dispute resolution', 'Contract performance and legitimate interest.'),
              _divider(),
              _purposeRow('Fraud prevention, safety, and platform integrity', 'Legitimate interest, legal obligation, public interest where applicable.'),
              _divider(),
              _purposeRow('Merchant/rider onboarding and KYC', 'Contract performance, legal obligation, legitimate interest.'),
              _divider(),
              _purposeRow('Marketing and promotions', 'Consent where required, or legitimate interest where permitted and opt-out is provided.'),
              _divider(),
              _purposeRow('Analytics and service improvement', 'Legitimate interest or consent where required.'),
              _divider(),
              _purposeRow('Legal compliance, audits, and regulatory response', 'Legal obligation and legitimate interest.'),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('5. Recipient Data'),
            _buildCard(children: [
              _bodyText(
                'If you provide a recipient\'s name, phone number, address, or delivery '
                'instruction, you confirm that you have a lawful basis to provide it to '
                'DropX for delivery. DropX uses recipient data to complete delivery, '
                'support proof of delivery, resolve disputes, and comply with law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('6. Rider Location Data'),
            _buildCard(children: [
              _bodyText(
                'DropX may process rider location during active platform use and active '
                'delivery for dispatch, navigation, safety, proof of delivery, dispute '
                'resolution, fraud prevention, payout verification, and operational '
                'monitoring. Location data is not used beyond legitimate platform purposes.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('7. Sharing Personal Data'),
            _buildCard(children: [
              _bodyText('DropX may share data with:'),
              const SizedBox(height: 8),
              _bullet('Merchants, to fulfil orders.'),
              _bullet('Riders and logistics partners, to complete pickup and delivery.'),
              _bullet('Payment processors, banks, and fraud-prevention providers.'),
              _bullet('Cloud hosting, analytics, messaging, mapping, and support vendors.'),
              _bullet('Professional advisers, auditors, insurers, and legal representatives.'),
              _bullet('Regulators, courts, law enforcement, or government bodies where required or lawful.'),
              _bullet('Business successors in connection with merger, acquisition, or restructuring, subject to safeguards.'),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('8. International Transfers'),
            _buildCard(children: [
              _bodyText(
                'Some service providers may process data outside Nigeria. DropX ensures '
                'that international transfers are made with appropriate safeguards under '
                'applicable data protection law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('9. Retention'),
            _buildCard(children: [
              _bodyText(
                'DropX keeps personal data only as long as reasonably necessary for the '
                'purposes described in this notice, including legal, tax, accounting, '
                'fraud-prevention, dispute, safety, and regulatory needs.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('10. Your Rights'),
            _buildCard(children: [
              _bodyText('Subject to applicable law, you may have rights to:'),
              const SizedBox(height: 8),
              _bullet('Access your personal data.'),
              _bullet('Correct inaccurate data.'),
              _bullet('Delete data in appropriate cases.'),
              _bullet('Object to or restrict processing.'),
              _bullet('Withdraw consent where processing is based on consent.'),
              _bullet('Request portability where applicable.'),
              _bullet('Lodge a complaint with the relevant data protection authority.'),
              const SizedBox(height: 8),
              _bodyText(
                'Requests may be sent to hello@dropx.africa or support@dropx.africa. '
                'DropX may verify your identity before responding.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('11. Marketing Choices'),
            _buildCard(children: [
              _bodyText(
                'You may opt out of marketing messages using available unsubscribe tools '
                'or by contacting support. Operational, transactional, safety, delivery, '
                'legal, or account messages may still be sent.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('12. Security'),
            _buildCard(children: [
              _bodyText(
                'DropX uses reasonable technical and organisational measures to protect '
                'personal data, including access controls, role-based permissions, audit '
                'logs, encryption where appropriate, secure development practices, '
                'incident response, and vendor controls.',
              ),
              const SizedBox(height: 8),
              _bodyText(
                'No system is completely secure. Users must protect their credentials '
                'and promptly report suspected compromise.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('13. Children'),
            _buildCard(children: [
              _bodyText(
                'DropX is not intended for persons under 18. Users must not create '
                'accounts for minors or allow minors to use DropX unsupervised.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('14. Data Breach'),
            _buildCard(children: [
              _bodyText(
                'DropX will assess suspected personal data breaches under its Data '
                'Breach Response Policy and notify affected persons or regulators '
                'where required by applicable law.',
              ),
            ]),
            const SizedBox(height: 16),

            _sectionHeader('15. Changes'),
            _buildCard(children: [
              _bodyText(
                'DropX may update this notice by app, website, email, or other '
                'reasonable notice. Material changes will be communicated clearly.',
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
              child: AppText(text, fontSize: 14, color: AppColors.slate500, height: 1.5),
            ),
          ],
        ),
      );

  Widget _divider() =>
      const Divider(height: 16, color: AppColors.slate100);

  Widget _purposeRow(String purpose, String basis) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              purpose,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBackground,
            ),
            const SizedBox(height: 3),
            AppText(
              basis,
              fontSize: 13,
              color: AppColors.slate500,
              height: 1.45,
            ),
          ],
        ),
      );
}
