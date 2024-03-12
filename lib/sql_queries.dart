class SqlQueries {
  static List<String> databaseCreationV1 = [
    'CREATE TABLE "exercises" ("id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT)',
    'CREATE TABLE "workout_templates" ("id" INTEGER PRIMARY KEY, "workout_name" TEXT)',
    'CREATE TABLE "workout_template_exercises" ("id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER)',
    'CREATE TABLE "workout_session" ("id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER)',
    'CREATE TABLE "workout_session_exercises" ("id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER)'
  ];

  static List<String> databaseCreationV2 = [
    'CREATE TABLE "exercises" ( "id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT, "exercise_description" TEXT )',
    'CREATE TABLE "workout_session" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER, "workout_session_name" TEXT, "workout_session_note" TEXT, FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_session_exercises" ( "id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("workout_session_id") REFERENCES "workout_session"("id"), FOREIGN KEY("exercise_id") REFERENCES "exercises"("id") )',
    'CREATE TABLE "workout_template_exercises" ( "id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("exercise_id") REFERENCES "exercises"("id"), FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_templates" ( "id" INTEGER PRIMARY KEY, "workout_name" TEXT, "workout_description" TEXT, "workout_day" INTEGER )'
  ];

  static List<String> databaseUpgradeV1toV2 = [
    'CREATE TABLE IF NOT EXISTS "exercises_temp" ( "id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT, "exercise_description" TEXT )',
    'CREATE TABLE IF NOT EXISTS "workout_session_temp" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER, "workout_session_name" TEXT, "workout_session_note" TEXT, FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE IF NOT EXISTS "workout_session_exercises_temp" ( "id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("workout_session_id") REFERENCES "workout_session_temp"("id"), FOREIGN KEY("exercise_id") REFERENCES "exercises_temp"("id") )',
    'CREATE TABLE IF NOT EXISTS "workout_template_exercises_temp" ( "id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("exercise_id") REFERENCES "exercises_temp"("id"), FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'INSERT INTO "exercises_temp"("id", "exercise_name", "exercise_video") SELECT "id", "exercise_name", "exercise_video" FROM "exercises"',
    'INSERT INTO "workout_session_temp"("id", "workout_template_id", "start_time", "duration") SELECT "id", "workout_template_id", "start_time", "duration" FROM "workout_session"',
    'INSERT INTO "workout_session_exercises_temp"("id", "workout_session_id", "exercise_id", "rep_set", "exercise_index") SELECT "id", "workout_session_id", "exercise_id", "rep_set", "exercise_index" FROM "workout_session_exercises"',
    'INSERT INTO "workout_template_exercises_temp"("id", "exercise_id", "workout_template_id", "rep_set", "exercise_index") SELECT "id", "exercise_id", "workout_template_id", "rep_set", "exercise_index" FROM "workout_template_exercises"',
    'DROP TABLE IF EXISTS "exercises"',
    'DROP TABLE IF EXISTS "workout_session"',
    'DROP TABLE IF EXISTS "workout_session_exercises"',
    'DROP TABLE IF EXISTS "workout_template_exercises"',
    'ALTER TABLE "exercises_temp" RENAME TO "exercises"',
    'ALTER TABLE "workout_session_temp" RENAME TO "workout_session"',
    'ALTER TABLE "workout_session_exercises_temp" RENAME TO "workout_session_exercises"',
    'ALTER TABLE "workout_template_exercises_temp" RENAME TO "workout_template_exercises"'
  ];
}
