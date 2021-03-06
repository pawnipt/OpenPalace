package net.codecomposer.palace.rpc.webservice
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import net.codecomposer.palace.model.PalaceConfig;
	import net.codecomposer.palace.model.PalaceProp;
	
	// OPWS = Open Palace Web Service
	public class OPWSConfirmPropsUpload extends EventDispatcher
	{
		private var _loader:URLLoader;
		
		private var _props:Array;
		
		public function send(props:Array):void {
			var requestDefs:Array = [];
			for each (var prop:PalaceProp in props) {
				if (prop.asset.guid) {
					var requestDef:Object = {};
					requestDef['guid'] = prop.asset.guid;
					requestDefs.push(requestDef);
				}
			}
			var request:URLRequest = new URLRequest(PalaceConfig.webServiceURL + "/props/confirm_upload");
			request.contentType = 'application/json';
			request.method = URLRequestMethod.POST;
			request.requestHeaders = [
				new URLRequestHeader('Accept', 'application/json')
			];
			request.data = JSON.encode({
				api_version: 1,
				api_key: OPWSParameters.API_KEY,
				props: requestDefs
			});

			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.TEXT;
			_loader.addEventListener(Event.COMPLETE, handleComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			_loader.load(request);
		}
		
		private function handleIOError(event:IOErrorEvent):void {
			dispatchEvent(new OPWSEvent(OPWSEvent.FAULT_EVENT));			
		}
		
		private function handleSecurityError(event:SecurityErrorEvent):void {
			dispatchEvent(new OPWSEvent(OPWSEvent.FAULT_EVENT));			
		}
		
		private function handleComplete(event:Event):void {
			var e:OPWSEvent = new OPWSEvent(OPWSEvent.RESULT_EVENT);
			try {
				e.result = JSON.decode(String(_loader.data));
			}
			catch(error:Error) {
				throw new Error("Unable to decode JSON response: " + error.name + ":\n" + error.message);
			}
			dispatchEvent(e);
		}
	}
}