
import SwiftUI

struct ContentView: View {
    
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var isValidPhone: Bool {
        phoneNumber.count == 10 &&
        phoneNumber.allSatisfy { $0.isNumber }
    }
    
    var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }
    
    var isFormValid: Bool {
        isValidEmail && isValidPhone && !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                Image(.swift)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x: 100, y: 170)
                    .opacity(0.20)
                
                Image(.c)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x: -120, y: -170)
                    .opacity(0.20)
                
                Image(.html)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x: -50, y: 280)
                    .opacity(0.20)
                
                Image(.python)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x: 100, y: -280)
                    .opacity(0.20)
                
                Image(.java)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.20)
                
                VStack(spacing: 12) {
                    
                    Text("Programmer's Corner")
                        .font(.system(size: 25, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "envelope")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField("Email", text: $email)
                                .font(.subheadline)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Phone Number")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "phone")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField(
                                "10-digit phone number",
                                text: $phoneNumber
                            )
                            .font(.subheadline)
                            .keyboardType(.numberPad)
                            .onChange(of: phoneNumber) {
                                phoneNumber = String(
                                    phoneNumber
                                        .filter { $0.isNumber }
                                        .prefix(10)
                                )
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "lock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if showPassword {
                                TextField("Password", text: $password)
                                    .font(.subheadline)
                            } else {
                                SecureField("Password", text: $password)
                                    .font(.subheadline)
                            }
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(
                                    systemName: showPassword
                                    ? "eye.slash"
                                    : "eye"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button("Forgot Password?") {
                            print("Forgot Password")
                        }
                        .font(.caption2)
                    }
                    
                    NavigationLink {
                        HomeView(email: email)
                    } label: {
                        Text("Login")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                isFormValid
                                ? Color.blue
                                : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .disabled(!isFormValid)
                    
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        
                        Button("Sign Up") {
                            print("Sign Up")
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.caption2)
                }
                .padding(20)
                .frame(maxWidth: 360)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
            }
        }
    }
}

struct HomeView: View {
    
    let email: String
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 55))
                    .foregroundStyle(.blue)
                
                Text("Welcome to the Homepage")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text("Welcome back!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                
                Divider()
                    .padding(.horizontal, 30)
                
                VStack(spacing: 15) {
                    HomeButton(
                        icon: "swift",
                        title: "Swift Programming"
                    )
                    
                    HomeButton(
                        icon: "chevron.left.forwardslash.chevron.right",
                        title: "Coding Practice"
                    )
                    
                    HomeButton(
                        icon: "book.fill",
                        title: "Learning Resources"
                    )
                }
                .padding(.horizontal, 25)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HomeButton: View {
    
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 40)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    ContentView()
}
 
   


