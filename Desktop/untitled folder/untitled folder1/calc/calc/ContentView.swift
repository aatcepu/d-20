import SwiftUI
import Playgrounds

struct ContentView: View {
    @State private var maths:String = ""
    @State private var physics:String = ""
    @State private var chemistry:String = ""
    @State private var totalMarks:Double = 0.0
    @State private var percentage:Double = 0.0
    @State private var grade:String = ""
    var body: some View {
        ZStack{
            
            Color.gray.opacity(0.15)
                .ignoresSafeArea()
            
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue.opacity(0.15))
                .offset(x: 100, y: -300)
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 140))
                .foregroundStyle(.blue.opacity(0.15))
                .offset(x: -100, y: -100)
            Image(systemName: "pencil.and.ruler.fill")
                .font(.system(size: 120))
                .foregroundStyle(.blue.opacity(0.15))
                .offset(x: 100, y: 100)
            Image(systemName: "book.fill")
                .font(.system(size: 120))
                .foregroundStyle(.yellow.opacity(0.15))
                .offset(x: -100, y: 300)
        
        VStack(spacing:20)
            {
                Text("Student Grade Calculator")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        
                        .black
                    )
                
                HStack {
                    TextField("Enter Maths Marks 0-100",text: $maths)
                        .padding()
                    Image(systemName: "ruler")
                        .foregroundStyle(.gray)
                }.frame(width:350, height:60)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius:15)
                HStack {
                    TextField("Enter Physics Marks 0-100",text: $physics)
                        .padding()
                    Image(systemName: "atom")
                        .foregroundStyle(.gray)
                }.frame(width:350, height:60)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius:15)
                HStack {
                    TextField("Enter Chemistry Marks 0-100",text: $chemistry)
                        .padding()
                    Image(systemName: "flask")
                        .foregroundStyle(.gray)
                }.frame(width:350, height:60)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .shadow(radius:15)
                
                Button
                {
                    
                }label: {
                    Text("Calculate")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font((.system(size: 20)))
                        .frame(width:300,height: 60)
                        .background(.black)
                        .foregroundStyle(.yellow.opacity(0.15))
                        .cornerRadius(15)
                    
                }
                Text("Total Marks: \(totalMarks,specifier:"%.2f")/300")
            }.frame(width: 380, height:450)
                .background(.gray.opacity(0.50))
                .cornerRadius(20)
        }
    }

}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
