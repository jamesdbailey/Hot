/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2020 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa

public class GraphView: NSView
{
    public var data = [ Int ]()
    
    public func addData( temperature: Int )
    {
        self.data.append( temperature )
        
        self.data         = self.data.suffix( 50 )
        self.needsDisplay = true
    }
    
    public var canDisplay: Bool
    {
        self.data.count >= 2
    }
    
    public override func draw( _ rect: NSRect )
    {
        if self.canDisplay == false
        {
            return
        }
        
        let graphOutlinePath = NSBezierPath( roundedRect: rect.insetBy( dx: 1, dy: 1 ), xRadius: 10, yRadius: 10 )
        
        NSColor.controlTextColor.withAlphaComponent( 0.2 ).setStroke()
        NSColor.controlTextColor.withAlphaComponent( 0.05 ).setFill()
        graphOutlinePath.stroke()
        graphOutlinePath.fill()
        
        let tempPath  = NSBezierPath()
        var i      = CGFloat( 0 )
        let rect   = rect.insetBy( dx: 10, dy: 10 )
        
        for i in 0 ... 100
        {
            if i % 10 != 0 || i < 30
            {
                continue
            }
            
            let line = NSBezierPath()
            let y    = CGFloat( rect.origin.y + ( CGFloat( i ) * rect.size.height / CGFloat( 100 ) ) )
            
            line.move( to: NSMakePoint( rect.origin.x, y ) )
            line.line( to: NSMakePoint( rect.origin.x + rect.size.width, y ) )
            
            NSColor.controlTextColor.withAlphaComponent( 0.075 ).setStroke()
            line.stroke()
        }
        
        var tempStart  = NSMakePoint( 0, 0 )
        var tempEnd    = NSMakePoint( 0, 0 )
        var tempLowest = CGFloat( 100 )
        
        for value in self.data
        {
            let n = value > 100 ? CGFloat( 100 ) : CGFloat( value )
            let x  = (  i * ( rect.size.width  / CGFloat( self.data.count - 1 ) ) ) + rect.origin.x
            let y = ( n * ( rect.size.height / 100 ) ) + rect.origin.y
                        
            if y < tempLowest
            {
                tempLowest = y
            }
            
            if i == 0
            {
                tempStart = NSMakePoint( x, y )
                
                tempPath.move( to: tempStart )
                
            }
            else
            {
                tempEnd = NSMakePoint( x, y )
                
                tempPath.line( to: tempEnd )
            }
            
            i += 1
        }
        
        tempPath.lineWidth    = 2
        tempPath.lineCapStyle = .round
        
        NSColor.systemBlue.withAlphaComponent( 0.75 ).setStroke()
        
        NSColor.systemOrange.withAlphaComponent( 0.75 ).setStroke()
        tempPath.stroke()
        
        if UserDefaults.standard.bool( forKey: "DrawGraphGradient" )
        {
            let fill = tempPath.copy() as! NSBezierPath
            
            fill.line( to: NSMakePoint( tempEnd.x, tempLowest - 20 ) )
            fill.line( to: NSMakePoint( rect.origin.x, tempLowest - 20 ) )
            
            fill.close()
            
            NSGradient( colors: [ NSColor.systemOrange.withAlphaComponent( 0.75 ), NSColor.clear ] )?.draw( in: fill, angle: -90 )
        }
        
        let circle = NSBezierPath( ovalIn: NSMakeRect( rect.origin.x, rect.origin.y,      7.5, 7.5 ) )
        
        NSColor.systemBlue.withAlphaComponent( 0.75 ).setFill()
        
        NSColor.systemOrange.withAlphaComponent( 0.75 ).setFill()
        circle.fill()
        
        let attributes: [ NSAttributedString.Key : Any ] =
        [
            .foregroundColor : NSColor.controlTextColor.withAlphaComponent( 0.75 ),
            .font            : NSFont.systemFont( ofSize: 8 )
        ]
        
        ( "CPU Temperature" as NSString ).draw( at: NSMakePoint( rect.origin.x + 10, rect.origin.y - 1 ), withAttributes: attributes )
    }
}
