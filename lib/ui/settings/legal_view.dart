import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum LegalType { privacy, terms }

class LegalView extends StatelessWidget {
  final LegalType type;

  const LegalView({super.key, required this.type});

  String get _title =>
      type == LegalType.privacy ? '개인정보처리방침' : '서비스 이용약관';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: type == LegalType.privacy
              ? _privacyPolicySections()
              : _termsOfServiceSections(),
        ),
      ),
    );
  }

  // ──────────────────────────────────────
  // 개인정보처리방침
  // ──────────────────────────────────────
  List<Widget> _privacyPolicySections() {
    return [
      _buildNotice('시행일: 2026년 2월 13일'),
      const SizedBox(height: 16),
      _buildParagraph(
        '체크 알리미(이하 "앱")는 「개인정보 보호법」 제30조에 따라 '
        '이용자의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 '
        '처리할 수 있도록 다음과 같이 개인정보 처리방침을 수립·공개합니다.',
      ),
      const SizedBox(height: 24),
      _buildSection('제1조 (수집하는 개인정보 항목)', [
        '앱은 서비스 제공을 위해 다음 개인정보를 수집합니다.',
        '',
        '• 필수 항목: 이메일 주소',
        '• 소셜 로그인 시: 이메일, 이름 (Google/Apple 제공 정보)',
        '• 서비스 이용 기록: 체크 항목명, 알림 설정, 반복 주기',
      ]),
      _buildSection('제2조 (개인정보의 수집 및 이용 목적)', [
        '수집한 개인정보는 다음 목적으로만 이용됩니다.',
        '',
        '• 회원 가입 및 본인 확인',
        '• 습관 관리 서비스 제공 (체크 항목 저장, 알림 발송)',
        '• 서비스 개선 및 오류 대응',
      ]),
      _buildSection('제3조 (개인정보의 보유 및 파기)', [
        '• 보유 기간: 회원 탈퇴 시까지',
        '• 파기 절차: 탈퇴 요청 시 지체 없이 해당 정보를 파기합니다.',
        '• 파기 방법: 전자적 파일은 복구 불가능한 방법으로 삭제합니다.',
      ]),
      _buildSection('제4조 (개인정보의 제3자 제공)', [
        '앱은 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. '
            '다만, 다음의 경우에는 예외로 합니다.',
        '',
        '• 이용자가 사전에 동의한 경우',
        '• 법령에 의거하여 제공이 요구되는 경우',
      ]),
      _buildSection('제5조 (개인정보 처리 위탁)', [
        '앱은 서비스 운영을 위해 다음과 같이 개인정보 처리를 위탁합니다.',
        '',
        '• 위탁 업체: Google LLC (Firebase)',
        '• 위탁 업무: 사용자 인증, 데이터 저장 및 관리',
      ]),
      _buildSection('제6조 (이용자의 권리와 행사 방법)', [
        '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.',
        '',
        '• 개인정보 열람, 수정, 삭제 요청',
        '• 회원 탈퇴를 통한 개인정보 처리 정지 요청',
        '',
        '권리 행사는 앱 내 설정 또는 이메일을 통해 가능합니다.',
      ]),
      _buildSection('제7조 (개인정보의 안전성 확보 조치)', [
        '앱은 개인정보의 안전성 확보를 위해 다음 조치를 취합니다.',
        '',
        '• 비밀번호 암호화 저장',
        '• SSL/TLS를 통한 데이터 전송 암호화',
        '• Firebase 보안 규칙을 통한 접근 제어',
      ]),
      const SizedBox(height: 16),
    ];
  }

  // ──────────────────────────────────────
  // 서비스 이용약관
  // ──────────────────────────────────────
  List<Widget> _termsOfServiceSections() {
    return [
      _buildNotice('시행일: 2026년 2월 13일'),
      const SizedBox(height: 16),
      _buildSection('제1조 (목적)', [
        '본 약관은 체크 알리미(이하 "앱")가 제공하는 습관 관리 서비스의 '
            '이용과 관련하여 앱과 이용자 간의 권리, 의무 및 책임사항을 규정함을 '
            '목적으로 합니다.',
      ]),
      _buildSection('제2조 (서비스의 내용)', [
        '앱은 다음과 같은 서비스를 제공합니다.',
        '',
        '• 체크 항목 생성, 수정, 삭제',
        '• 반복 알림 설정 (주간, 월간, 특정 날짜)',
        '• 달력을 통한 습관 기록 조회',
      ]),
      _buildSection('제3조 (이용자의 의무)', [
        '이용자는 다음 행위를 해서는 안 됩니다.',
        '',
        '• 타인의 개인정보를 도용하는 행위',
        '• 서비스 운영을 방해하는 행위',
        '• 관련 법령에 위반되는 행위',
      ]),
      _buildSection('제4조 (서비스의 변경 및 중단)', [
        '• 앱은 운영상, 기술상의 필요에 따라 서비스를 변경할 수 있습니다.',
        '• 서비스 변경 시 변경 내용과 적용일자를 사전에 공지합니다.',
        '• 천재지변, 시스템 장애 등 불가항력적 사유 발생 시 서비스가 '
            '일시 중단될 수 있습니다.',
      ]),
      _buildSection('제5조 (면책조항)', [
        '• 앱은 무료로 제공되며, 서비스 이용과 관련하여 발생한 '
            '손해에 대해 책임을 지지 않습니다.',
        '• 이용자의 귀책사유로 인한 서비스 이용 장애에 대해서는 '
            '책임을 지지 않습니다.',
        '• 알림은 기기 설정 및 네트워크 상태에 따라 지연되거나 '
            '수신되지 않을 수 있습니다.',
      ]),
      _buildSection('제6조 (약관의 변경)', [
        '• 본 약관은 관련 법령에 위배되지 않는 범위 내에서 변경될 수 있습니다.',
        '• 약관이 변경될 경우, 적용일자 10일 전부터 앱 내에서 공지합니다.',
        '• 이용자에게 불리한 변경의 경우, 적용일자 30일 전부터 공지합니다.',
      ]),
      const SizedBox(height: 16),
    ];
  }

  // ──────────────────────────────────────
  // 공통 위젯
  // ──────────────────────────────────────
  Widget _buildNotice(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> paragraphs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subtitle2Bold,
          ),
          const SizedBox(height: 8),
          ...paragraphs.map((p) => p.isEmpty
              ? const SizedBox(height: 6)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    p,
                    style: AppTextStyles.body2Regular.copyWith(
                      color: AppColors.onSurface,
                      height: 1.6,
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: AppTextStyles.body2Regular.copyWith(
        color: AppColors.onSurface,
        height: 1.6,
      ),
    );
  }
}
