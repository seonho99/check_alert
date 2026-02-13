import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/datasource/auth_datasource.dart';
import '../../data/datasource/task_datasource.dart';
import '../../data/repository_impl/auth_repository_impl.dart';
import '../../data/repository_impl/task_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/task_repository.dart';
import '../../domain/usecase/auth/apple_sign_in_usecase.dart';
import '../../domain/usecase/auth/google_sign_in_usecase.dart';
import '../../domain/usecase/auth/sign_in_usecase.dart';
import '../../domain/usecase/auth/sign_up_usecase.dart';
import '../../domain/usecase/auth/sign_out_usecase.dart';
import '../../domain/usecase/task/get_tasks_usecase.dart';
import '../../domain/usecase/task/add_task_usecase.dart';
import '../../domain/usecase/task/update_task_usecase.dart';
import '../../domain/usecase/task/delete_task_usecase.dart';

/// Domain Provider (Repository, UseCase)
List<SingleChildWidget> buildDomainProviders() {
  return [
    // Repositories
    Provider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        dataSource: context.read<AuthDataSource>(),
      ),
    ),
    Provider<TaskRepository>(
      create: (context) => TaskRepositoryImpl(
        dataSource: context.read<TaskDataSource>(),
      ),
    ),

    // Auth UseCases
    Provider(
      create: (context) => SignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => SignUpUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => AppleSignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => GoogleSignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => SignOutUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),

    // Task UseCases
    Provider(
      create: (context) => GetTasksUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => AddTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => UpdateTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => DeleteTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
  ];
}
