import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/loading_util.dart';
import '../../../core/utils/logger_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'fault_code_detail_page.dart';

class FaultCodeQueryPage extends StatefulWidget {
  const FaultCodeQueryPage({Key? key}) : super(key: key);

  @override
  _FaultCodeQueryPageState createState() => _FaultCodeQueryPageState();
}

class _FaultCodeQueryPageState extends State<FaultCodeQueryPage> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onTextChanged);
    _codeController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onTextChanged() {
    final text = _codeController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(text);
    });
  }

  Future<void> _fetchSuggestions(String keyword) async {
    if (keyword.isEmpty) return;

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final response = await ApiService.searchFaultCodesQuick(
        keyword: keyword,
        limit: 10,
      );
      LoggerUtil.i("模糊匹配的response----$response");
      if (response.success && response.data != null) {
        final responseData = response.data;
        final List<dynamic> faultCodes = responseData?['data']!['fault_codes'] ?? [];
        LoggerUtil.i("模糊匹配的列表----$faultCodes");
        setState(() {
          _suggestions = faultCodes;
          _showSuggestions = faultCodes.isNotEmpty;
          _isLoadingSuggestions = false;
          LoggerUtil.i("模糊匹配的列表length----${_suggestions.length}");
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      LoggerUtil.e('Failed to fetch suggestions: $e');
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
    }
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final String code = suggestion['code'] ?? '';
    _codeController.text = code;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _searchFaultCode();
  }

  Future<void> _searchFaultCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter fault code',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() {
      _showSuggestions = false;
    });

    try {
      LoadingUtil.show(context, message: 'Searching...');
      final response = await ApiService.getFaultCodeDetail(code);
      LoadingUtil.hide();

      if (response.success && response.data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaultCodeDetailPage(
              faultCodeData: response.data!,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? 'Search failed',
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      LoadingUtil.hide();
      LoggerUtil.e('Fault code search failed: $e');
      Fluttertoast.showToast(
        msg: 'Search failed, please try again',
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fault code query-R32',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children:[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Faulty model number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    suffixIcon: _isLoadingSuggestions
                        ? const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    )
                        : null,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _searchFaultCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Find',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showSuggestions && _suggestions.isNotEmpty)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 100,
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        LoggerUtil.e('suggestion=====$suggestion');

                        // 获取数据字段，提供默认值
                        final String code = suggestion['code']?.toString() ?? 'Unknown';
                        final String title = suggestion['title']?.toString() ?? '';
                        final String deviceModel = suggestion['device_model']?.toString() ?? '';

                        return ListTile(
                          title: Text(
                            code,  // 显示实际的故障码
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            title,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            deviceModel,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                          onTap: () => _selectSuggestion(suggestion),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ]
        ),
      ),
    );
  }
}