//
//  ContentView.swift
//  Drawing
//
//  Created by David Ruiz on 25/05/23.
//

import SwiftUI


struct Flower: Shape {
    var petalOffset = -20.0
    var petalWidth = 100.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8){
            let rotation = CGAffineTransform(rotationAngle: number)
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width * 0.5))
            
            let rotatedPetal = originalPetal.applying(position)
            
            path.addPath(rotatedPetal)
        }
        
        return path
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct Arc: InsettableShape {
    let startAngle: Angle
    let endAngle: Angle
    let clockwise: Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width*0.5 - insetAmount, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

struct Trapezoid: Shape {
    var insetAmount: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
    }
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
}

struct ColorCyclcingCircle: View {
    var amount = 0.0
    var steps = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Circle()
                    .inset(by: Double(value))
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color(for: value, brigthness: 1),
                                color(for: value, brigthness: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
        }
        .drawingGroup()
    }
    
    func color(for value: Int, brigthness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount
        
        if targetHue > 1 {
            targetHue -= 1
        }
        
        return Color(hue: targetHue, saturation: 1.0, brightness: brigthness)
    }
}

struct Checkerboard: Shape {
    var rows: Int
    var columns: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // figure out how big each row/column needs to be
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)
        
        // loop over all rows and columns, making alternating squares colored
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    // this square should be colored; add a rectangle here
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)
                    
                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }
        
        return path
    }
    
    
    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(Double(rows), Double(columns))
        }
        
        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }
}

struct Spirograph: Shape {
    let innerRadius: Int
    let outerRadius: Int
    let distance: Int
    let amount: Double
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        
        return a
    }
    
    func path(in rect: CGRect) -> Path {
        let divisor = gcd(innerRadius, outerRadius)
        let outerRadius = Double(self.outerRadius)
        let innerRadius = Double(self.innerRadius)
        let distance = Double(self.distance)
        let difference = innerRadius - outerRadius
        let endPoint = ceil(2 * Double.pi * outerRadius / Double(divisor)) * amount
        
        var path = Path()
        
        for theta in stride(from: 0, through: endPoint, by: 0.01) {
            var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
            var y = difference * sin(theta) - distance * sin(difference / outerRadius * theta)
            
            x += rect.width / 2
            y += rect.height / 2
            
            if theta == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

struct ContentView: View {
    
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    @State private var colorCycle = 0.0
    @State private var amount = 0.0
    @State private var insetAmount = 50.0
    @State private var rows = 4
    @State private var columns = 4
    
    @State private var innerRadius = 125.0
    @State private var outerRadius = 75.0
    @State private var distance = 25.0
    @State private var samount = 1.0
    @State private var hue = 0.6
    
    var body: some View {
        
        ScrollView{
            VStack{
                VStack(spacing: 0) {
                    Spacer()
                    
                    Spirograph(innerRadius: Int(innerRadius), outerRadius: Int(outerRadius), distance: Int(distance), amount: samount)
                        .stroke(Color(hue: hue, saturation: 1, brightness: 1), lineWidth: 1)
                        .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    Group {
                        Text("Inner radius: \(Int(innerRadius))")
                        Slider(value: $innerRadius, in: 10...150, step: 1)
                            .padding([.horizontal, .bottom])
                        
                        Text("Outer radius: \(Int(outerRadius))")
                        Slider(value: $outerRadius, in: 10...150, step: 1)
                            .padding([.horizontal, .bottom])
                        
                        Text("Distance: \(Int(distance))")
                        Slider(value: $distance, in: 1...150, step: 1)
                            .padding([.horizontal, .bottom])
                        
                        Text("Amount: \(samount, format: .number.precision(.fractionLength(2)))")
                        Slider(value: $samount)
                            .padding([.horizontal, .bottom])
                        
                        Text("Color")
                        Slider(value: $hue)
                            .padding(.horizontal)
                    }
                }
                
                
                //
                Checkerboard(rows: rows, columns: columns)
                    .onTapGesture {
                        withAnimation(.linear(duration: 3)) {
                            rows = 8
                            columns = 16
                        }
                    }
                
                //
                VStack {
                    ZStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 200 * amount)
                            .offset(x: -50, y: -80)
                            .blendMode(.screen)
                        
                        Circle()
                            .fill(.green)
                            .frame(width: 200 * amount)
                            .offset(x: 50, y: -80)
                            .blendMode(.screen)
                        
                        Circle()
                            .fill(.blue)
                            .frame(width: 200 * amount)
                            .blendMode(.screen)
                    }
                    .frame(width: 300, height: 300)
                    
                    Slider(value: $amount)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .ignoresSafeArea()
                
                
                //
                Trapezoid(insetAmount: insetAmount)
                    .frame(width: 200, height: 100)
                    .onTapGesture {
                        withAnimation {
                            insetAmount = Double.random(in: 10...90)
                        }
                    }
                
                VStack {
                    //
                    Image("Example")
                        .colorMultiply(.red)
                    
                    
                    //
                    ColorCyclcingCircle(amount: colorCycle)
                        .frame(width: 300, height: 300)
                    
                    Text("Color cycle")
                    Slider(value: $colorCycle)
                        .padding([.horizontal, .bottom])
                    
                    //
                    Text("Hello, world!")
                        .frame(width: 300, height: 300)
                        .border(ImagePaint(image: Image("Example"), scale:0.2), width: 50)
                    
                    Capsule()
                        .strokeBorder(ImagePaint(image: Image("Example"), scale: 0.1), lineWidth: 20)
                        .frame(width: 300, height: 200)
                }
                
                VStack {
                    //
                    VStack {
                        Flower(petalOffset: petalOffset, petalWidth: petalWidth)
                            .fill(.red, style: FillStyle(eoFill: true, antialiased: true))
                        
                        Text("Offset")
                        Slider(value: $petalOffset, in: -40...40)
                            .padding([.horizontal, .bottom])
                        
                        Text("Width")
                        Slider(value: $petalWidth, in: 0...100)
                            .padding([.horizontal, .bottom])
                        
                    }
                    .frame(width: 400, height: 1000)
                    
                    
                    //
                    Triangle()
                        .fill(.red)
                        .frame(width: 200, height: 200)
                    
                    //
                    Arc(startAngle: .degrees(0), endAngle: .degrees(-180), clockwise: true)
                        .strokeBorder(.cyan, lineWidth: 10)
                        .frame(width: 200, height: 200)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
