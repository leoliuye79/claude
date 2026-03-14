import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/agent.dart';
import '../../providers/agent_provider.dart';
import '../../providers/database_provider.dart';

class CustomAgentScreen extends ConsumerStatefulWidget {
  const CustomAgentScreen({super.key});

  @override
  ConsumerState<CustomAgentScreen> createState() => _CustomAgentScreenState();
}

class _CustomAgentScreenState extends ConsumerState<CustomAgentScreen> {
  final _nameController = TextEditingController();
  final _nameZhController = TextEditingController();
  final _personalityController = TextEditingController();
  final _greetingController = TextEditingController();
  final _topicsController = TextEditingController();
  AgentRole _role = AgentRole.friend;
  TeachingStyle _style = TeachingStyle.encouraging;
  CorrectionMode _correctionMode = CorrectionMode.immediate;
  String _targetLevel = '中级';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameZhController.dispose();
    _personalityController.dispose();
    _greetingController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _nameZhController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写英文名和中文名')),
      );
      return;
    }

    setState(() => _saving = true);

    final agent = Agent(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      nameZh: _nameZhController.text.trim(),
      avatarUrl: '',
      role: _role,
      style: _style,
      correctionMode: _correctionMode,
      personality: _personalityController.text.trim().isNotEmpty
          ? _personalityController.text.trim()
          : 'A friendly language learning companion',
      greeting: _greetingController.text.trim().isNotEmpty
          ? _greetingController.text.trim()
          : 'Hi! Nice to meet you!',
      targetLevel: _targetLevel,
      topics: _topicsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      final repo = ref.read(agentRepositoryProvider);
      await repo.insertAgent(agent);
      await ref.read(agentsProvider.notifier).refresh();
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建自定义 Agent'),
        backgroundColor: AppColors.appBarDark,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white))
                : const Text('保存',
                    style: TextStyle(color: AppColors.white, fontSize: 16)),
          ),
        ],
      ),
      backgroundColor: AppColors.chatBackground,
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildSection('基本信息', [
            _buildTextField('英文名 *', _nameController, 'e.g. Alex'),
            const Divider(indent: 16),
            _buildTextField('中文名 *', _nameZhController, 'e.g. 亚历克斯'),
            const Divider(indent: 16),
            _buildTextField('性格描述', _personalityController,
                'e.g. Friendly and patient'),
            const Divider(indent: 16),
            _buildTextField('打招呼', _greetingController, 'e.g. Hey there!'),
          ]),
          const SizedBox(height: 12),
          _buildSection('角色设置', [
            _buildDropdown<AgentRole>(
              '角色',
              _role,
              AgentRole.values,
              (v) => v.label,
              (v) => setState(() => _role = v),
            ),
            const Divider(indent: 16),
            _buildDropdown<TeachingStyle>(
              '教学风格',
              _style,
              TeachingStyle.values,
              (v) => v.name,
              (v) => setState(() => _style = v),
            ),
            const Divider(indent: 16),
            _buildDropdown<CorrectionMode>(
              '纠错模式',
              _correctionMode,
              CorrectionMode.values,
              (v) => v.name,
              (v) => setState(() => _correctionMode = v),
            ),
            const Divider(indent: 16),
            _buildDropdown<String>(
              '目标等级',
              _targetLevel,
              ['初级', '中级', '高级', '全级别'],
              (v) => v,
              (v) => setState(() => _targetLevel = v),
            ),
          ]),
          const SizedBox(height: 12),
          _buildSection('话题', [
            _buildTextField('话题（逗号分隔）', _topicsController,
                'e.g. movies, music, cooking'),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppDimensions.fontSm)),
        ),
        Container(
          color: AppColors.white,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textPrimary)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items,
      String Function(T) labelFn, ValueChanged<T> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: AppDimensions.fontMd,
                    color: AppColors.textPrimary)),
          ),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: items
                  .map((v) => DropdownMenuItem<T>(
                        value: v,
                        child: Text(labelFn(v)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
