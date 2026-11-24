import Foundation

/// The optional `event` script runs only if it is a regular file owned by the current user and not
/// writable by group/others (prevents another account or process from swapping it).
func isSafeToRunScript(atPath path: String, uid: uid_t = getuid(), fileManager: FileManager = .default) -> Bool {
    guard let attrs = try? fileManager.attributesOfItem(atPath: path),
          attrs[.type] as? FileAttributeType == .typeRegular,
          (attrs[.ownerAccountID] as? NSNumber)?.uint32Value == uid,
          let perms = attrs[.posixPermissions] as? NSNumber,
          perms.intValue & 0o022 == 0 else { return false }
    return true
}
