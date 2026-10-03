
import SwiftUI

struct PythonCoursePage: View {
    
    let chapters = [
        "Introduction to Python",
        "Python Basics",
        "Conditional Statements",
        "Loops",
        "Strings",
        "Lists",
        "Tuples and Sets",
        "Dictionaries",
        "Functions",
        "Modules and Packages",
        "File Handling",
        "Exception Handling",
        "Object-Oriented Programming",
        "Advanced Python",
        "Python Libraries",
        "Database Programming",
        "Data Science with Python",
        "AI and Machine Learning",
        "Web Development with Python",
        "Python Projects"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                Text("Python Programming")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                ForEach(0..<chapters.count, id: \.self) { index in
                    
                    NavigationLink {
                        Text(chapters[index])
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                    } label: {
                        HStack {
                            
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 45, height: 45)
                                .background(Color.green)
                                .clipShape(Circle())
                            
                            Text(chapters[index])
                                .font(.headline)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Python")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PythonCoursePage()
    }
}
