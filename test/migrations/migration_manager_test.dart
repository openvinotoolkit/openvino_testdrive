// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/migration/migration.dart';
import 'package:inference/migration/migration_manager.dart';

import 'package:mocktail/mocktail.dart';

class MockMigration extends Mock implements Migration {
  @override
  final String from;
  @override
  final String to;

  MockMigration({required this.from, required this.to});
}

void main() {
  group("eligible", () {
    final migrationManager = MigrationManager(
      destinationVersion: "2",
      manifest: [],
      migrations: [
        MockMigration(from: "1", to: "2")
      ]
    );

    test("project json is eligible for migration if migration for version exists", () {
        final projectJson = {
          "application_version": "1",
        };

        expect(migrationManager.eligible(projectJson), true);
    });
    test("project json is ineligible for migration if migration for version does not exists", () {
        final projectJson = {
          "application_version": "0",
        };

        expect(migrationManager.eligible(projectJson), false);
    });
  });

  group("migrate",  () {
     test("migration is called with project", () {
        final migration = MockMigration(from: "1", to: "2");

        final migrationManager = MigrationManager(
          destinationVersion: "2",
          manifest: [],
          migrations: [
            migration,
          ]
        );


        final projectJson = {
          "some_value": 1,
          "application_version": "1",
        };

        final expectedOutput = {
          "changed_value": 1,
          "application_version": "2",
        };
        when(() => migration.migrate(any(), [])).thenReturn(expectedOutput);

        final output = migrationManager.migrate(projectJson);
        verify(() => migration.migrate(any(), [])).called(1);
        expect(output, expectedOutput);
     });

     test("migrations are chained as long as a eligible migration exists", () {
        final migration_1 = MockMigration(from: "1", to: "2");
        final migration_2 = MockMigration(from: "2", to: "3");

        final migrationManager = MigrationManager(
          destinationVersion: "3",
          manifest: [],
          migrations: [
            migration_1,
            migration_2,
          ]
        );

        final projectJson = {"application_version": "1"};
        when(() => migration_1.migrate(any(), [])).thenReturn({"application_version": "2"});
        when(() => migration_2.migrate(any(), [])).thenReturn({"application_version": "3"});

        migrationManager.migrate(projectJson);
        verify(() => migration_1.migrate(any(), [])).called(1);
        verify(() => migration_2.migrate(any(), [])).called(1);
     });

     test("migrations are applied up to destinationVersion", () {
        final migration_1 = MockMigration(from: "1", to: "2");
        final migration_2 = MockMigration(from: "2", to: "3");

        // TODO: use destination version?
        final migrationManager = MigrationManager(
          destinationVersion: "2",
          manifest: [],
          migrations: [
            migration_1,
            migration_2,
          ]
        );

        final projectJson = {"application_version": "1"};
        when(() => migration_1.migrate(any(), [])).thenReturn({"application_version": "2"});
        when(() => migration_2.migrate(any(), [])).thenReturn({"application_version": "3"});

        migrationManager.migrate(projectJson);
        verify(() => migration_1.migrate(any(), [])).called(1);
        verifyNever(() => migration_2.migrate(any(), []));
     });
  });
}
