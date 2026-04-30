//
//  AuthView.swift
//  NobleCut
//
//  Created by OpenAI Codex on 30.04.26.
//

import SwiftUI

struct AuthView: View {
    enum Field: Hashable {
        case loginUsername
        case loginPassword
        case registerFullName
        case registerUsername
        case registerPassword
    }

    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    @State private var isContentVisible = false
    @State private var hasAnimatedOnce = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    heroCard
                        .screenEntrance(isVisible: isContentVisible)

                    formCard
                        .screenEntrance(isVisible: isContentVisible, delay: 0.08)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            guard !hasAnimatedOnce else {
                isContentVisible = true
                return
            }

            hasAnimatedOnce = true
            isContentVisible = true
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("home_desc_background")
                .resizable()
                .scaledToFill()
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.42),
                    Color.black.opacity(0.88)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.mode.eyebrowTitle)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .kerning(1.8)
                    .foregroundStyle(.appYellow)

                Text("NOBLECUT")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.82))

                Text(viewModel.mode.headline)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(5)

                Text(viewModel.mode.description)
                    .font(.system(size: 16, design: .serif))
                    .foregroundStyle(.white.opacity(0.76))
                    .lineSpacing(7)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
        .frame(height: 320)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.26), radius: 24, x: 0, y: 12)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.mode.cardTitle)
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text("This form talks directly to SmartAppt auth and stores the returned JWT on this device.")
                    .font(.system(size: 14, design: .serif))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineSpacing(5)
            }

            VStack(spacing: 14) {
                if viewModel.mode == .login {
                    usernameField(
                        title: "Username",
                        text: $viewModel.loginUsername,
                        field: .loginUsername
                    )

                    passwordField(
                        title: "Password",
                        text: $viewModel.loginPassword,
                        field: .loginPassword
                    )
                } else {
                    fullNameField

                    usernameField(
                        title: "Username",
                        text: $viewModel.registerUsername,
                        field: .registerUsername
                    )

                    passwordField(
                        title: "Password",
                        text: $viewModel.registerPassword,
                        field: .registerPassword
                    )
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundStyle(.appYellow)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.darkGray.opacity(0.58))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appYellow.opacity(0.34), lineWidth: 1)
                    }
            }

            Button {
                focusedField = nil
                Task {
                    await viewModel.submit()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.black)
                    }

                    Text(viewModel.isSubmitting ? "PROCESSING" : viewModel.mode.primaryButtonTitle)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .tracking(0.6)
                }
                .foregroundStyle(Color.black.opacity(0.82))
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.appYellow)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSubmitting)
            .opacity(viewModel.isSubmitting ? 0.82 : 1)

            HStack(spacing: 6) {
                Text(viewModel.mode.secondaryPrompt)
                    .foregroundStyle(.white.opacity(0.62))

                Button(viewModel.mode.secondaryActionTitle) {
                    focusedField = nil
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.switchMode()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundStyle(.appYellow)
            }
            .font(.system(size: 14, weight: .medium, design: .serif))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
    }

    private var fullNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("Full Name")

            TextField("Enter your full name", text: $viewModel.registerFullName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focusedField, equals: .registerFullName)
                .onSubmit {
                    focusedField = .registerUsername
                }
                .authFieldStyle()
        }
    }

    private func usernameField(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            TextField("Enter your username", text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(nextField(after: field) == nil ? .go : .next)
                .focused($focusedField, equals: field)
                .onSubmit {
                    focusedField = nextField(after: field)
                }
                .authFieldStyle()
        }
    }

    private func passwordField(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(title)

            SecureField("Enter your password", text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .focused($focusedField, equals: field)
                .onSubmit {
                    focusedField = nil
                    Task {
                        await viewModel.submit()
                    }
                }
                .authFieldStyle()
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .semibold, design: .serif))
            .kerning(1.2)
            .foregroundStyle(.white.opacity(0.54))
    }

    private func nextField(after field: Field) -> Field? {
        switch field {
        case .loginUsername:
            return .loginPassword
        case .registerFullName:
            return .registerUsername
        case .registerUsername:
            return .registerPassword
        case .loginPassword, .registerPassword:
            return nil
        }
    }
}

private extension View {
    func authFieldStyle() -> some View {
        self
            .font(.system(size: 17, weight: .medium, design: .serif))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.darkGray.opacity(0.62))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
    }
}

#Preview {
    AuthView(
        viewModel: AuthViewModel(repository: AuthRepository()) { _ in }
    )
    .preferredColorScheme(.dark)
}
