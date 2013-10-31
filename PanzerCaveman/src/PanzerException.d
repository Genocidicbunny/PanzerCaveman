module pzc.pzcexception;

class  PZCException : Exception {
private:

public:
	this(string msg) { 
		super(msg); 
	} 
}