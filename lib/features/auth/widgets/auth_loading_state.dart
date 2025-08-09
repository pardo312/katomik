import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/platform/platform_service.dart';

class AuthLoadingState extends StatelessWidget {
  final String? message;
  
  const AuthLoadingState({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (context.isIOS)
            const CupertinoActivityIndicator(radius: 16)
          else
            const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}