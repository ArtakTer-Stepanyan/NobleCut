//
//  URLConfiguration.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 01.05.26.
//

import Foundation

enum URLConfiguration {
    private static let hostMachineIPKey = "NOBLECUT_HOST_MACHINE_IP"

    static func resolvedURL(
        infoDictionaryKey: String,
        environmentKey: String,
        fallbackURLString: String
    ) -> URL {
        let rawURLString = ProcessInfo.processInfo.environment[environmentKey]
            ?? Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            ?? fallbackURLString

        guard let baseURL = URL(string: rawURLString) else {
            preconditionFailure("Invalid URL configured for \(environmentKey): \(rawURLString)")
        }

        return rewriteLoopbackHostIfNeeded(baseURL)
    }

    private static func rewriteLoopbackHostIfNeeded(_ url: URL) -> URL {
#if targetEnvironment(simulator)
        return url
#else
        guard let host = url.host, host.isLoopbackHost else {
            return url
        }

        guard let replacementHost = configuredHostMachineIP else {
            return url
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        components.host = replacementHost
        return components.url ?? url
#endif
    }

    private static var configuredHostMachineIP: String? {
        let rawValue = ProcessInfo.processInfo.environment[hostMachineIPKey]
            ?? Bundle.main.object(forInfoDictionaryKey: hostMachineIPKey) as? String

        guard let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}


private extension String {
    var isLoopbackHost: Bool {
        self == "localhost" || self == "127.0.0.1" || self == "::1"
    }
}
