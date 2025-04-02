import java.awt.*;
import java.net.*;
import java.awt.event.*;
import java.applet.*;
import javax.swing.*;
public class Java extends Applet implements ActionListener
{
	Button btn;

	public void init(){
		btn = new Button("call Flex()");
		add(btn);
		btn.addActionListener(this);
	}

	public void actionPerformed (ActionEvent evt){
		if(evt.getSource() == btn){
			try {
				getAppletContext().showDocument(new URL("javascript:flex.showAlert(\"Hello from Java Applet\")"));
			}catch (MalformedURLException me){}
		}
	}

	public void sayHello(){
		JOptionPane.showMessageDialog( null, "Hello from Flex", "Adobe Flex :-)", JOptionPane.INFORMATION_MESSAGE);
	}
}
