class Linea{
	const numero
	const packs = []
	const consumos = []
	var tipoLinea 
	const deudas = []
	
	method cambiarTipo(nuevaL){
		tipoLinea = nuevaL
	}
	
	method agregarPack(unP){
		packs.add(unP)
	}
	
	method costoPromedio(min,max) = self.consumosEntre(min,max).sum({unC => unC.costo()}) / self.cantConsumos()
	
	method consumosEntre(min,max) = consumos.filter({unC => unC.entreFechas(min,max)})
	
	method cantConsumos() = consumos.size()
	
	method consumosUltimos30Dias() = self.consumosEntre(new Date().minusMonths(1),new Date())
	
	method puedeHacerConsumo(unC) = packs.any({unP => unP.puedeSatisfacer(unC)})
	
	method realizarConsumo(unC){
		if(self.puedeHacerConsumo(unC)){
			self.consumirPack(unC)
		}else{
			tipoLinea.consumoTipo(unC)
		}
	}
	
	method consumirPack(unC){
			consumos.add(unC)
			const pack = packs.reverse().find({unP => unP.puedeSatisfacer(unC)})
			pack.gastarPack(unC)
	}
	
	method limpiezaPacks(){
		
	}
	
	method packsVencidos() = packs.filter({unP => unP.pasado()})
	
	method agregarDeuda(unC){
		deudas.add(unC)
	}
}

class Black inherits Linea{
	
	method consumoTipo(unC){
		self.agregarDeuda(unC)
	}
}

class Platinum inherits Linea{
	method consumoTipo(unC){
		consumos.add(unC)
	}
}

class Comun inherits Linea{
	method consumoTipo(unC){
		self.error("NO SE PUEDE REALIZAR EL CONSUMO")
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////

class Consumo{
	const fecha = new Date()
	method fecha() = fecha	
	method entreFechas(min,max) = fecha.between(min,max)
	
	method esInternet() = false
	method esLlamada() = false
}

class ConsumoInternet inherits Consumo{
	const mbs
	method mbs() = mbs
	
	method costo() = mbs * empresa.precioMB()
	
	override method esInternet() = true
}

class ConsumoLlamadas inherits Consumo{
	const segundos
	method segundos() = segundos
	
	method costo() =  empresa.costoFijo() + segundos * empresa.precioLlamada()
	
	override method esLlamada() = true
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////

class Pack{
	const fechaVen
	
	method puedeSatisfacer(unC) = not self.pasado() && self.condParticular(unC)
	
	method pasado() = self.vencido() || self.agotado()
	
	method vencido() = fechaVen < new Date()
	
	method agotado()
	
	method condParticular(unC)
}

class PackConsumos inherits Pack{
	const consumos = []
	const cantidad
	
	method gastarPack(unC){
		consumos.add(unC)
	}
	
	override method agotado() = self.cantRestante() <= 0
	
	method cantRestante() = cantidad - self.totalConsumos()
	
	method totalConsumos() = consumos.sum({unC => unC.costo()})
}

class CreditoDisp inherits PackConsumos{
	
	override method condParticular(unC) = unC.costo() <= cantidad
}

class MBlibres inherits PackConsumos{
	
	override method condParticular(unC) = unC.mbs() <= cantidad && unC.esInternet()
}

class MBlibresPlus inherits MBlibres{
	override method condParticular(unC) = unC.mbs() <= 0.1
}

class Llamadas inherits Pack{
	const segundos
	
	override method condParticular(unC) = unC.segundos() <= segundos && unC.esLlamada()
}

class InternetIlimitado inherits Pack{
	
	override method condParticular(unC) = unC.fecha().internalDayOfWeek() > 5 && unC.esInternet()
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

object empresa{
	var costoFijo
	var precioMB
	var precioLlamada
	
	method costoFijo() = costoFijo
	method precioMB() = precioMB
	method precioLlamada() = precioLlamada
}