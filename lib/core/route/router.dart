import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/local_notification_service.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/task_repository.dart';
import '../../domain/usecase/auth/apple_sign_in_usecase.dart';
import '../../domain/usecase/auth/google_sign_in_usecase.dart';
import '../../domain/usecase/auth/sign_in_usecase.dart';
import '../../domain/usecase/auth/sign_up_usecase.dart';
import '../../domain/usecase/task/get_tasks_usecase.dart';
import '../../domain/usecase/task/add_task_usecase.dart';
import '../../domain/usecase/task/update_task_usecase.dart';
import '../../domain/usecase/task/delete_task_usecase.dart';

import '../../ui/auth/sign_in/sign_in_view.dart';
import '../../ui/auth/sign_in/sign_in_viewmodel.dart';
import '../../ui/auth/sign_up/sign_up_view.dart';
import '../../ui/auth/sign_up/sign_up_viewmodel.dart';
import '../../ui/task_list/task_list_view.dart';
import '../../ui/task_list/task_list_viewmodel.dart';
import '../../ui/task_detail/task_detail_view.dart';
import '../../ui/task_detail/task_detail_viewmodel.dart';
import '../../ui/settings/legal_view.dart';
import '../../ui/settings/settings_view.dart';

/// 라우트 경로 상수
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String taskDetail = '/tasks/detail';
  static const String taskAdd = '/tasks/add';
  static const String settings = '/settings';
  static const String legalPrivacy = '/settings/privacy';
  static const String legalTerms = '/settings/terms';
}

/// GoRouter 설정
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.signIn,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => ChangeNotifierProvider(
        create: (ctx) => TaskListViewModel(
          getTasksUseCase: ctx.read<GetTasksUseCase>(),
          deleteTaskUseCase: ctx.read<DeleteTaskUseCase>(),
          authRepository: ctx.read<AuthRepository>(),
          notificationService: ctx.read<LocalNotificationService>(),
        ),
        child: const TaskListView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => ChangeNotifierProvider(
        create: (ctx) => SignInViewModel(
          signInUseCase: ctx.read<SignInUseCase>(),
          googleSignInUseCase: ctx.read<GoogleSignInUseCase>(),
          appleSignInUseCase: ctx.read<AppleSignInUseCase>(),
        ),
        child: const SignInView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => ChangeNotifierProvider(
        create: (ctx) => SignUpViewModel(
          signUpUseCase: ctx.read<SignUpUseCase>(),
        ),
        child: const SignUpView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.taskAdd,
      builder: (context, state) => ChangeNotifierProvider(
        create: (ctx) => TaskDetailViewModel(
          addTaskUseCase: ctx.read<AddTaskUseCase>(),
          updateTaskUseCase: ctx.read<UpdateTaskUseCase>(),
          authRepository: ctx.read<AuthRepository>(),
          taskRepository: ctx.read<TaskRepository>(),
          notificationService: ctx.read<LocalNotificationService>(),
        ),
        child: const TaskDetailView(),
      ),
    ),
    GoRoute(
      path: AppRoutes.taskDetail,
      builder: (context, state) {
        final taskId = state.uri.queryParameters['id'];
        return ChangeNotifierProvider(
          create: (ctx) => TaskDetailViewModel(
            addTaskUseCase: ctx.read<AddTaskUseCase>(),
            updateTaskUseCase: ctx.read<UpdateTaskUseCase>(),
            authRepository: ctx.read<AuthRepository>(),
            taskRepository: ctx.read<TaskRepository>(),
            notificationService: ctx.read<LocalNotificationService>(),
            taskId: taskId,
          ),
          child: const TaskDetailView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsView(),
    ),
    GoRoute(
      path: AppRoutes.legalPrivacy,
      builder: (context, state) => const LegalView(type: LegalType.privacy),
    ),
    GoRoute(
      path: AppRoutes.legalTerms,
      builder: (context, state) => const LegalView(type: LegalType.terms),
    ),
  ],
);
