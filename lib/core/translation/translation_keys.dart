// ignore_for_file: constant_identifier_names

import 'dart:ui';

import '../cache/cache_keys.dart';

abstract class TranslationKeys {
  static const Locale localeEN = Locale(CacheKeys.keyEN);
  static const Locale localeAR = Locale(CacheKeys.keyAR);
  static const welcomeToDoIt = "welcome To\nDo It !";
  static const readyToConquer =
      "Ready to conquer your tasks? Let's Do It together.";
  static const letStart = "Let's Start";
  static const register = "register";
  static const dontHaveAnAccount = "dontHaveAnAccount";
  static const alreadyHaveAnAccount = "alreadyHaveAnAccount";
  static const login = "login";
  static const signupFailed = "signupFailed";
  static const hello = "hello";
  static const adventurer = "adventurer";
  static const male = "male";
  static const female = "female";
  static const addTask = "addTask";
  static const title = "title";
  static const description = "description";
  static const group = "group";
  static const endDate = "endDate";
  static const settings = "Settings";
  static const language = "language";
  static const AR = "AR";
  static const EN = "EN";
  static const updateProfile = "Update Profile";
  static const changePassword = "Change Password";
  static const update = "update";
  static const Username = "Username";
  static const ConfirmPassword = "Confirm Password";
  static const Password = "Password";
  static const Pleaseselectanoption = "Please select an option";
  static const Passwordisrequired = "Password is required'";
  static const Passwordnotmatched = "Password not matched";
  static const Passwordmustbeatleast6characters =
      "Password must be at least 6 characters";
  static const Usernamemustbe3_16 = "Username must be 3-16";
  static const Usernameisrequired = "Username is required";
  static const Fieldisrequired = "Field is required";
  static const Tasks = "Tasks";
  static const Notasksavailable = "No tasks available";
  static const Results = "Results";
  static const TherearenotasksyetnPressthebuttonnToaddNewTask =
      "There are no tasks yet,\nPress the button\nTo add New Task";
  static const InProgress = "In Progress";
  static const Done = "Done";
  static const TaskGroups = "Task Groups";
  static const MissedTask = "Missed Task";
  static const Believeyouanandyourehalfwaythere =
      "Believe you can, and you\\'re halfway there.";
  static const Congrats = "Congrats!";
  static const ThereisAlwaysanotherchance = "There is Always another chance.";
  static const editTask = "editTask";
  static const markAsDone = "markAsDone";
  static const delete = "delete";
  static const viewTasks = "viewTasks";
  static const yourTodaysTasksAlmostDone = "yourTodaysTasksAlmostDone";
  static const filter = "filter";
  static const home = "home";
  static const work = "work";
  static const personal = "personal";
  static const all = "all";
  static const done = "done";
  static const missed = "missed";
  static const inProgress = "inProgress";
  static const Search = "Search";
}
