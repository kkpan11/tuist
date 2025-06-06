import Foundation
import TuistCore
import TuistSupport

/// Tuist Workspace Identifier Mapper
///
/// A mapper that includes a known file within the generated xcworkspace directory.
/// This is used to help identify the workspace as one that has been generated by tuist.
final class TuistWorkspaceIdentifierMapper: WorkspaceMapping {
    func map(workspace: WorkspaceWithProjects) throws -> (WorkspaceWithProjects, [SideEffectDescriptor]) {
        Logger.current.debug("Transforming workspace \(workspace.workspace.name): Signing the workspace")

        let tuistGeneratedFileDescriptor = FileDescriptor(
            path: workspace
                .workspace
                .xcWorkspacePath
                .appending(
                    component: Constants.tuistGeneratedFileName
                )
        )

        return (workspace, [
            .file(tuistGeneratedFileDescriptor),
        ])
    }
}
