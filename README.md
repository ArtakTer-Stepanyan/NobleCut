# NobleCut

NobleCut is a modern SwiftUI iOS app prototype built around a premium barbershop experience.

The app includes:
- A polished authentication flow with login and registration
- JWT session persistence
- Service browsing
- Barber discovery
- Appointment booking
- Reservation management

The interface is designed with a bold luxury style, using a refined black-and-gold visual language across the app.

## Local backend from iOS

`NobleCut` defaults to:
- `http://localhost:5011/api` for the main API
- `http://localhost:5141/api/Auth` for the auth API

That works in the iOS Simulator. On a physical iPhone, `localhost` points to the phone itself, so you must use your Mac's LAN IP instead.

The auth endpoints themselves do not require a JWT:
- `POST /api/Auth/login`
- `POST /api/Auth/register/customer`

But customer actions in `SmartAppt.API` do require a JWT bearer token:
- `POST /api/customers`
- `POST /api/customers/bookings`
- `GET /api/customers/bookings`

The iOS app should keep the JWT returned by auth and send it to the main API for those requests.

### Real-device checklist

1. Put the Mac and iPhone on the same Wi-Fi network.
2. Start both backend services on all interfaces, not only `localhost`.
3. Set `NOBLECUT_HOST_MACHINE_IP` in Xcode to your Mac's LAN IP, for example `192.168.100.196`.

The app will keep using `localhost` on the simulator, and automatically rewrite loopback URLs to `NOBLECUT_HOST_MACHINE_IP` on device builds.

### Important SmartAppt limitation

This backend currently has no anonymous endpoint that lists customer-visible services. The only open customer-facing main API endpoints are:
- `/api/business/{businessId}/services/{serviceId}/calendar/{year}/{month}`
- `/api/business/{businessId}/services/{serviceId}/calendar/{year}/{month}/{day}/slots`

Because of that, the iOS app needs a configured service catalog unless the backend adds a public services endpoint.

Set these values in the Xcode target build settings or scheme environment:
- `NOBLECUT_BUSINESS_ID`
- `NOBLECUT_HAIRCUT_SERVICE_ID`
- `NOBLECUT_TRIM_SERVICE_ID`
- `NOBLECUT_DELUXE_SERVICE_ID`

Once those IDs are set, the app can:
- show backend-backed services instead of local-only mocks
- load availability from `SmartAppt.API`
- create the customer profile on first booking if needed
- create and fetch real bookings with the JWT from auth

### Backend launch examples

Main API:

```bash
ASPNETCORE_URLS=http://0.0.0.0:5011 dotnet run --project src/API/SmartAppt.API
```

Auth API:

```bash
ASPNETCORE_URLS=http://0.0.0.0:5141 dotnet run --project auth-service/authService.API
```

If Rider launch profiles are still using `http://localhost:5011` and `http://localhost:5141`, a physical iPhone will not be able to reach them.
