import Foundation

/// FileManager-based translation storage
/// Caches translations in Application Support directory (permanent storage)
public actor TranslationStorage {
    private let fileManager: FileManager
    private let cacheDirectory: URL

    public init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        // Get Application Support directory for permanent storage
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw StorageError.cacheDirectoryNotFound
        }

        // Create LocalizeKit/Translations subdirectory
        self.cacheDirectory = appSupportURL
            .appendingPathComponent("LocalizeKit", isDirectory: true)
            .appendingPathComponent("Translations", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

    /// Save translation file to cache
    /// - Parameters:
    ///   - translationFile: Translation file to save
    ///   - languageCode: Language code (e.g., "en", "bn")
    public func save(_ translationFile: TranslationFile, for languageCode: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(languageCode).json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(translationFile)

        try data.write(to: fileURL, options: .atomic)
    }

    /// Load translation file from cache
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    /// - Returns: Translation file if exists, nil otherwise
    public func load(for languageCode: String) throws -> TranslationFile? {
        let fileURL = cacheDirectory.appendingPathComponent("\(languageCode).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(TranslationFile.self, from: data)
    }

    /// Check cache state by loading file and comparing version with server version
    /// - Parameter language: Language object with code and server version
    /// - Returns: Cache state (valid, stale, missing, or corrupted)
    public func checkCacheState(for language: Language) async -> CacheState {
        do {
            // Try to load cached file
            guard let cachedFile = try load(for: language.code) else {
                return .missing
            }

            // Compare version from cached file with server version
            if cachedFile.version == language.version {
                return .valid(cachedFile: cachedFile)
            } else {
                return .stale(cachedVersion: cachedFile.version)
            }
        } catch {
            // File exists but couldn't be loaded (corrupted)
            let fileURL = cacheDirectory.appendingPathComponent("\(language.code).json")
            if fileManager.fileExists(atPath: fileURL.path) {
                return .corrupted
            } else {
                return .missing
            }
        }
    }

    /// Delete cached translation file (alias for delete method)
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    public func deleteCacheFile(for languageCode: String) throws {
        try delete(for: languageCode)
    }

    /// Check if translation file exists in cache
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    /// - Returns: True if cached file exists
    public func exists(for languageCode: String) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(languageCode).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Delete cached translation file
    /// - Parameter languageCode: Language code (e.g., "en", "bn")
    public func delete(for languageCode: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(languageCode).json")

        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    /// Delete all cached translation files
    public func clearAll() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)

        for fileURL in contents where fileURL.pathExtension == "json" {
            try fileManager.removeItem(at: fileURL)
        }
    }

    /// Get cache directory path (for debugging)
    public func getCacheDirectoryPath() -> String {
        cacheDirectory.path
    }

    /// Get cached file info
    /// - Parameter languageCode: Language code
    /// - Returns: Tuple of (file size, modification date) if exists
    public func getCachedFileInfo(for languageCode: String) -> (size: Int64, modificationDate: Date)? {
        let fileURL = cacheDirectory.appendingPathComponent("\(languageCode).json")

        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path) else {
            return nil
        }

        let size = attributes[.size] as? Int64 ?? 0
        let modificationDate = attributes[.modificationDate] as? Date ?? Date()

        return (size, modificationDate)
    }

    /// List all cached language codes
    /// - Returns: Array of language codes that have cached files
    public func listCachedLanguages() throws -> [String] {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)

        return contents
            .filter { $0.pathExtension == "json" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }
}

// MARK: - Errors

public enum StorageError: LocalizedError {
    case cacheDirectoryNotFound
    case fileNotFound(String)
    case encodingFailed
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .cacheDirectoryNotFound:
            return "Cache directory not found"
        case .fileNotFound(let languageCode):
            return "Translation file not found for language: \(languageCode)"
        case .encodingFailed:
            return "Failed to encode translation data"
        case .decodingFailed:
            return "Failed to decode translation data"
        }
    }
}
