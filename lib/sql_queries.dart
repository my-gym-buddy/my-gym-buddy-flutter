class SqlQueries {  static List<String> databaseCreationV1 = [
    'CREATE TABLE "exercises" ("id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT)',
    'CREATE TABLE "workout_templates" ("id" INTEGER PRIMARY KEY, "workout_name" TEXT)',
    'CREATE TABLE "workout_template_exercises" ("id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER)',
    'CREATE TABLE "workout_session" ("id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER)',
    'CREATE TABLE "workout_session_exercises" ("id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER)'
  ];  static List<String> databaseCreationV2 = [
    'CREATE TABLE "exercises" ( "id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT, "exercise_description" TEXT )',
    'CREATE TABLE "workout_session" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER, "workout_session_name" TEXT, "workout_session_note" TEXT, FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_session_exercises" ( "id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("workout_session_id") REFERENCES "workout_session"("id"), FOREIGN KEY("exercise_id") REFERENCES "exercises"("id") )',
    'CREATE TABLE "workout_template_exercises" ( "id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("exercise_id") REFERENCES "exercises"("id"), FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_templates" ( "id" INTEGER PRIMARY KEY, "workout_name" TEXT, "workout_description" TEXT, "workout_day" TEXT )'
  ];

  static List<String> databaseUpgradeV1toV2 = [
    'CREATE TABLE IF NOT EXISTS "exercises_temp" ( "id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT, "exercise_description" TEXT )',
    'CREATE TABLE IF NOT EXISTS "workout_session_temp" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER, "workout_session_name" TEXT, "workout_session_note" TEXT, FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE IF NOT EXISTS "workout_session_exercises_temp" ( "id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("workout_session_id") REFERENCES "workout_session_temp"("id"), FOREIGN KEY("exercise_id") REFERENCES "exercises_temp"("id") )',
    'CREATE TABLE IF NOT EXISTS "workout_template_exercises_temp" ( "id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("exercise_id") REFERENCES "exercises_temp"("id"), FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE IF NOT EXISTS "workout_templates_temp" ( "id" INTEGER PRIMARY KEY, "workout_name" TEXT, "workout_description" TEXT, "workout_day" TEXT )',
    'INSERT INTO "exercises_temp"("id", "exercise_name", "exercise_video") SELECT "id", "exercise_name", "exercise_video" FROM "exercises"',
    'INSERT INTO "workout_session_temp"("id", "workout_template_id", "start_time", "duration") SELECT "id", "workout_template_id", "start_time", "duration" FROM "workout_session"',
    'INSERT INTO "workout_session_exercises_temp"("id", "workout_session_id", "exercise_id", "rep_set", "exercise_index") SELECT "id", "workout_session_id", "exercise_id", "rep_set", "exercise_index" FROM "workout_session_exercises"',
    'INSERT INTO "workout_template_exercises_temp"("id", "exercise_id", "workout_template_id", "rep_set", "exercise_index") SELECT "id", "exercise_id", "workout_template_id", "rep_set", "exercise_index" FROM "workout_template_exercises"',
    'INSERT INTO "workout_templates_temp"("id", "workout_name", "workout_description", "workout_day") SELECT "id", "workout_name", "", null FROM "workout_templates"',
    'DROP TABLE IF EXISTS "exercises"',
    'DROP TABLE IF EXISTS "workout_session"',
    'DROP TABLE IF EXISTS "workout_session_exercises"',
    'DROP TABLE IF EXISTS "workout_template_exercises"',
    'DROP TABLE IF EXISTS "workout_templates"',
    'ALTER TABLE "exercises_temp" RENAME TO "exercises"',
    'ALTER TABLE "workout_session_temp" RENAME TO "workout_session"',
    'ALTER TABLE "workout_session_exercises_temp" RENAME TO "workout_session_exercises"',
    'ALTER TABLE "workout_template_exercises_temp" RENAME TO "workout_template_exercises"',
    'ALTER TABLE "workout_templates_temp" RENAME TO "workout_templates"'
  ];

  static List<String> databaseCreationV3 = [
    'CREATE TABLE "exercises" ( "id" INTEGER PRIMARY KEY, "exercise_name" TEXT, "exercise_video" TEXT, "exercise_description" TEXT, "exercise_category" TEXT, "exercise_difficulty" TEXT, "images" TEXT )',
    'CREATE TABLE "categories" ( "id" INTEGER PRIMARY KEY, "name" TEXT UNIQUE )',
    'CREATE TABLE "difficulties" ( "id" INTEGER PRIMARY KEY, "name" TEXT UNIQUE )',
    'CREATE TABLE "workout_session" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "start_time" TEXT, "duration" INTEGER, "workout_session_name" TEXT, "workout_session_note" TEXT, FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_session_exercises" ( "id" INTEGER PRIMARY KEY, "workout_session_id" INTEGER, "exercise_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("workout_session_id") REFERENCES "workout_session"("id"), FOREIGN KEY("exercise_id") REFERENCES "exercises"("id") )',
    'CREATE TABLE "workout_template_exercises" ( "id" INTEGER PRIMARY KEY, "exercise_id" INTEGER, "workout_template_id" INTEGER, "rep_set" TEXT, "exercise_index" INTEGER, FOREIGN KEY("exercise_id") REFERENCES "exercises"("id"), FOREIGN KEY("workout_template_id") REFERENCES "workout_templates"("id") )',
    'CREATE TABLE "workout_templates" ( "id" INTEGER PRIMARY KEY, "workout_name" TEXT, "workout_description" TEXT, "workout_day" TEXT )',
    'CREATE TABLE "temporary_workout" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "workout_data" TEXT, "start_time" TEXT, "duration" INTEGER )'
  ];
  static List<String> databaseUpgradeV2toV3 = [
    'ALTER TABLE "exercises" ADD COLUMN "exercise_category" TEXT',
    'ALTER TABLE "exercises" ADD COLUMN "exercise_difficulty" TEXT',
    'ALTER TABLE "exercises" ADD COLUMN "images" TEXT',
    'CREATE TABLE IF NOT EXISTS "categories" ( "id" INTEGER PRIMARY KEY, "name" TEXT UNIQUE )',
    'CREATE TABLE IF NOT EXISTS "difficulties" ( "id" INTEGER PRIMARY KEY, "name" TEXT UNIQUE )',
    'CREATE TABLE IF NOT EXISTS "temporary_workout" ( "id" INTEGER PRIMARY KEY, "workout_template_id" INTEGER, "workout_data" TEXT, "start_time" TEXT, "duration" INTEGER )'
  ];
}





