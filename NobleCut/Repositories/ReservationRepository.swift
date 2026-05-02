//
//  ReservationRepository.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import Foundation

protocol ReservationRepositoryProtocol: AnyObject {
    func fetchReservations() async throws -> [Reservation]
    func createReservation(service: Service, scheduledAt: Date) async throws -> Reservation
    func deleteReservation(id: String) async throws
}

final class ReservationRepository: ReservationRepositoryProtocol {
    private let apiService: any APIServiceProtocol
    private let sessionStore: any AuthSessionStoreProtocol
    private var storage: [Reservation]
    private var cachedServicesByID: [Int: Service] = [:]

    init(
        apiService: any APIServiceProtocol = APIService(),
        sessionStore: any AuthSessionStoreProtocol = AuthSessionStore.shared,
        storage: [Reservation] = []
    ) {
        self.apiService = apiService
        self.sessionStore = sessionStore
        self.storage = storage.sorted(by: Self.sortReservations)
    }

    func fetchReservations() async throws -> [Reservation] {
        do {
            let bookings = try await apiService.getCustomerBookings()
            let services = await loadRemoteServices()

            return bookings
                .map { makeReservation(from: $0, serviceLookup: services) }
                .sorted(by: Self.sortReservations)
        } catch let error as APIError where isMissingCustomerProfile(error) {
            return []
        }
    }

    func createReservation(service: Service, scheduledAt: Date) async throws -> Reservation {
        let resolvedService = APIConfiguration.resolvedConfiguredService(for: service)

        guard APIConfiguration.configuredBusinessID != nil else {
            let reservation = Reservation(service: service, scheduledAt: scheduledAt)
            storage.insert(reservation, at: 0)
            storage.sort(by: Self.sortReservations)
            return reservation
        }

        do {
            let booking = try await createRemoteBooking(
                serviceId: resolvedService.id,
                scheduledAt: scheduledAt
            )
            return makeReservation(from: booking, preferredService: resolvedService)
        } catch let error as APIError
            where error.statusCode == 404 &&
                error.localizedDescription.localizedCaseInsensitiveContains("customer not found") {
            try await createCustomerProfileIfNeeded()

            let booking = try await createRemoteBooking(
                serviceId: resolvedService.id,
                scheduledAt: scheduledAt
            )
            return makeReservation(from: booking, preferredService: resolvedService)
        }
    }

    private func createRemoteBooking(
        serviceId: Int,
        scheduledAt: Date
    ) async throws -> BookingPayload {
        try await apiService.createBooking(
            serviceId: serviceId,
            startAtUtc: scheduledAt.smartApptLocalDateTimeString,
            notes: nil
        )
    }

    private func createCustomerProfileIfNeeded() async throws {
        guard let session = sessionStore.loadSession() else {
            throw APIError.missingSession
        }

        do {
            let _: CustomerPayload = try await apiService.createCustomer(
                fullName: session.fullName,
                email: nil,
                phone: nil
            )
        } catch let error as APIError where isDuplicateCustomerInsert(error) {
            return
        }
    }

    private func loadRemoteServices() async -> [Int: Service] {
        if !cachedServicesByID.isEmpty {
            return cachedServicesByID
        }

        if let businessId = APIConfiguration.configuredBusinessID {
            do {
                let remoteServices = try await apiService.getServices(businessId: businessId)
                let resolvedServices = remoteServices.map(Service.init(remotePayload:))

                cachedServicesByID = Dictionary(
                    uniqueKeysWithValues: resolvedServices.map { ($0.id, $0) }
                )
                return cachedServicesByID
            } catch {
                print("[ReservationRepository] Failed to load remote services: \(error.localizedDescription)")
            }
        }

        let configuredServices = APIConfiguration.configuredServices
        cachedServicesByID = Dictionary(uniqueKeysWithValues: configuredServices.map { ($0.id, $0) })
        return cachedServicesByID
    }

    func deleteReservation(id: String) async throws {
        if let bookingID = Int(id) {
            do {
                let _: Bool = try await apiService.cancelCustomerBooking(id: bookingID)
                return
            } catch let error as APIError where error.statusCode == 404 {
                return
            }
        }

        let originalCount = storage.count
        storage.removeAll { $0.id == id }

        if storage.count == originalCount {
            throw APIError.server(statusCode: 404, message: "Reservation not found.")
        }
    }

    private func makeReservation(
        from booking: BookingPayload,
        preferredService: Service? = nil,
        serviceLookup: [Int: Service] = [:]
    ) -> Reservation {
        let fallbackService = Service(
            id: booking.serviceId,
            type: .haircut,
            price: 0,
            duration: max(Int(booking.endAtUtc.timeIntervalSince(booking.startAtUtc) / 60), 0),
            title: "Service #\(booking.serviceId)",
            details: "Backend booking"
        )

        let resolvedService = preferredService
            ?? serviceLookup[booking.serviceId]
            ?? fallbackService

        return Reservation(
            id: String(booking.bookingId),
            service: resolvedService,
            scheduledAt: booking.startAtUtc,
            createdAt: booking.startAtUtc,
            status: booking.status
        )
    }

    private static func sortReservations(lhs: Reservation, rhs: Reservation) -> Bool {
        lhs.scheduledAt < rhs.scheduledAt
    }

    private func isMissingCustomerProfile(_ error: APIError) -> Bool {
        error.statusCode == 404 &&
            error.localizedDescription.localizedCaseInsensitiveContains("customer not found")
    }

    private func isDuplicateCustomerInsert(_ error: APIError) -> Bool {
        let message = error.localizedDescription.lowercased()
        return (error.statusCode == 400 || error.statusCode == 500) &&
            (
                message.contains("duplicate") ||
                message.contains("unique") ||
                message.contains("ix_customer_userid")
            )
    }
}

private extension Date {
    var smartApptLocalDateTimeString: String {
        let calendar = BookingCalendarFactory.calendar
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self
        )

        return String(
            format: "%04d-%02d-%02dT%02d:%02d:%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0,
            components.hour ?? 0,
            components.minute ?? 0,
            components.second ?? 0
        )
    }
}
