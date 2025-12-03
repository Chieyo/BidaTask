import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'presentation/bloc/chat_list_cubit.dart';
import 'presentation/pages/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty || supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final chatRepository = ChatRepositoryImpl();
  runApp(MyApp(chatRepository: chatRepository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.chatRepository});

  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: chatRepository,
      child: MaterialApp(
        title: 'BidaTask Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: BlocProvider(
          create: (context) => ChatListCubit(
            chatRepository: RepositoryProvider.of<ChatRepository>(context),
          )..subscribeToChats(),
          child: const ChatListPage(),
        ),
      ),
    );
  }
}
