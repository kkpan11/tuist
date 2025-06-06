import Foundation
import Path
import TuistCore
import XcodeGraph
import XCTest

@testable import TuistTesting

final class TargetProjectMapperTests: XCTestCase {
    func test_map_project() throws {
        // Given
        let targetMapper = TargetMapper {
            var updated = $0
            updated.name = "Updated_\($0.name)"
            return (updated, [])
        }
        let subject = TargetProjectMapper(mapper: targetMapper)
        let targetA = Target.test(name: "A")
        let targetB = Target.test(name: "B")
        let project = Project.test(targets: [targetA, targetB])

        // When
        let (updatedProject, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEqual(updatedProject.targets.values.map(\.name).sorted(), [
            "Updated_A",
            "Updated_B",
        ])
        XCTAssertTrue(sideEffects.isEmpty)
    }

    func test_map_sideEffects() throws {
        // Given
        let targetMapper = TargetMapper {
            var updated = $0
            updated.name = "Updated_\($0.name)"
            return (updated, [.file(.init(path: try! AbsolutePath(validating: "/Targets/\($0.name).swift")))])
        }
        let subject = TargetProjectMapper(mapper: targetMapper)
        let targetA = Target.test(name: "A")
        let targetB = Target.test(name: "B")
        let project = Project.test(targets: [targetA, targetB])

        // When
        let (_, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEqual(sideEffects.sorted(by: { $0.description < $1.description }), [
            .file(.init(path: try AbsolutePath(validating: "/Targets/A.swift"))),
            .file(.init(path: try AbsolutePath(validating: "/Targets/B.swift"))),
        ])
    }

    // MARK: - Helpers

    private class TargetMapper: TargetMapping {
        let mapper: (Target) -> (Target, [SideEffectDescriptor])
        init(mapper: @escaping (Target) -> (Target, [SideEffectDescriptor])) {
            self.mapper = mapper
        }

        func map(target: Target) throws -> (Target, [SideEffectDescriptor]) {
            mapper(target)
        }
    }
}

final class SequentialProjectMapperTests: XCTestCase {
    func test_map_project() async throws {
        // Given
        let mapper1 = ProjectMapper {
            (Project.test(name: "Update1_\($0.name)"), [])
        }
        let mapper2 = ProjectMapper {
            (Project.test(name: "Update2_\($0.name)"), [])
        }
        let subject = SequentialProjectMapper(mappers: [mapper1, mapper2])
        let project = Project.test(name: "Project")

        // When
        let (updatedProject, sideEffects) = try await subject.map(project: project)

        // Then
        XCTAssertEqual(updatedProject.name, "Update2_Update1_Project")
        XCTAssertTrue(sideEffects.isEmpty)
    }

    func test_map_sideEffects() async throws {
        // Given
        let mapper1 = ProjectMapper {
            (Project.test(name: "Update1_\($0.name)"), [
                .command(.init(command: ["command 1"])),
            ])
        }
        let mapper2 = ProjectMapper {
            (Project.test(name: "Update2_\($0.name)"), [
                .command(.init(command: ["command 2"])),
            ])
        }
        let subject = SequentialProjectMapper(mappers: [mapper1, mapper2])
        let project = Project.test(name: "Project")

        // When
        let (_, sideEffects) = try await subject.map(project: project)

        // Then
        XCTAssertEqual(sideEffects, [
            .command(.init(command: ["command 1"])),
            .command(.init(command: ["command 2"])),
        ])
    }

    // MARK: - Helpers

    private class ProjectMapper: ProjectMapping {
        let mapper: (Project) -> (Project, [SideEffectDescriptor])
        init(mapper: @escaping (Project) -> (Project, [SideEffectDescriptor])) {
            self.mapper = mapper
        }

        func map(project: Project) throws -> (Project, [SideEffectDescriptor]) {
            mapper(project)
        }
    }
}
