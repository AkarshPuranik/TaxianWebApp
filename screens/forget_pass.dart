import 'package:flutter/material.dart';
import 'package:taxian_super_admin_web/style/pallet.dart';
import 'package:taxian_super_admin_web/widgets/TextField/text_field.dart';
import 'package:taxian_super_admin_web/widgets/customButton/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const id = "/ForgotPasswordScreen";

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController adminIdController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  int currentStep = 0;

  void handleContinue() {
    if (adminIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin ID cannot be empty")),
      );
      return;
    }
    setState(() => currentStep = 1);
  }

  void handleOtpSubmit() {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP cannot be empty")),
      );
      return;
    }
    setState(() => currentStep = 2);
  }

  void handleSavePassword() {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Pallet.primary,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentStep == 0
                    ? "Forgot Password"
                    : currentStep == 1
                    ? "Enter OTP"
                    : "Reset Password",
                style: const TextStyle(color: Pallet.secondary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),
              if (currentStep == 0)
                CustomTextField(
                  borderRadius: 5,
                  controller: adminIdController,
                  hintText: "Enter Admin ID",
                ),
              if (currentStep == 1)
                CustomTextField(
                  borderRadius: 5,
                  controller: otpController,
                  hintText: "Enter OTP",
                ),
              if (currentStep == 2) ...[
                CustomTextField(
                  borderRadius: 5,
                  controller: newPasswordController,
                  hintText: "Set New Password",
                ),
                CustomTextField(
                  borderRadius: 5,
                  controller: confirmPasswordController,
                  hintText: "Re-enter Password",
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                onPressed: currentStep == 0
                    ? handleContinue
                    : currentStep == 1
                    ? handleOtpSubmit
                    : handleSavePassword,
                backgroundColor: Pallet.secondary,
                child: Text(currentStep == 2 ? "Save" : currentStep == 1 ? "Submit" : "Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
