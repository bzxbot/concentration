# Trabalho Paradigmas de Programação
# Grupo 06
# Bernardo Botelho, Vinicius Bittencourt, Juliano Flores e Felipe Rabuske
# Jogo de Memória em linguagem Ruby
# Unisinos, Novembro de 2011

# IMPORTANTE
# Para executar o código é necessário possuir as bibliotecas Rubygame e SDL instaladas corretamente na máquina

require "rubygame"

include Rubygame
include Rubygame::Events
include Rubygame::EventActions
include Rubygame::EventTriggers

# Mostrar texto no console
$stdout.sync = true

# Ajustando escala/rotação com a letra S
$smooth = false

# Verificando se configuração esta setada corretamente
Rubygame.init()

# SDL_gfx é necessário para rotação/zoom
$gfx_ok = [:rotozoom, :zoom, :zoom_to].all? { |method|
  Rubygame::Surface.new([1,1]).respond_to?( method )
}

unless ( $gfx_ok )
	raise "Este demo necessita dos recursos de rotacao e zoom (SDL_gfx)"
end

# Ativa os modos de joysticks somente quando botões pressionados
# eventos aparecem na fila de eventos
Joystick.activate_all

#############################
# Classes de Eventos Padrão #
#############################

class Carta
	attr_accessor :rect, :virada, :tipo, :virada_sempre
	
	def initialize (rect, tipo)
		@rect = rect
		@tipo = tipo
		@virada = false
		@virada_sempre = false
	end

	def desenhar local
		if @virada
			s = Surface.load_image(@tipo + ".png")
			s.blit(local, [rect.x, rect.y])
			#local.draw_box( @rect.topleft, @rect.bottomright, @cor )
		else
			s = Surface.load_image("back.png")
			s.blit(local, [rect.x, rect.y])
			#local.draw_box( @rect.topleft, @rect.bottomright, [255,48,48] )
		end
	end
end

class Jogo
	
	def initialize(screen, queue)
		@screen = screen
		@background = Surface.new(screen.size)
		@queue = queue
		setup_clock
					
		@tipos_cartas = [ "7", "7", "rei", "rei", "rainha", "rainha", "as", "as"]
		@tipos_cartas = @tipos_cartas.sort_by{rand}		
		
		@cartas = Array.new
		for i in 0..3
			pos = 75 * i + 5 * (i+1)
			@cartas << Carta.new(Rect.new(pos,5,75,107), @tipos_cartas.pop) 
		end
		for i in 0..3
		   pos = 75 * i + 5 * (i+1)
			@cartas << Carta.new(Rect.new(pos,107+5+5,75,107), @tipos_cartas.pop) 
		end
		@prim_vir = nil
		@seg_vir = nil
	end
	
	def rodar
		loop do
			desenhar
		
			@background.blit(@screen,[0,0])
			
			@screen.update()
			
			@queue.fetch_sdl_events
			
			@queue.each do |event|
				
				case(event)
					when QuitEvent
						return			# Parada da função principal
					when MouseDownEvent
						puts "click: [%d,%d]"%event.pos
						@cartas.each do |carta|				
							if carta.rect.collide_point?(event.pos[0], event.pos[1])
								puts "COLISAO"
								
								if carta.virada != true and carta.virada_sempre != true
								
									@seg_vir_nil = @seg_vir
									
									if @prim_vir == nil
										@prim_vir = carta.tipo
									elsif @seg_vir == nil
										@seg_vir = carta.tipo
									end
									
									if @seg_vir != nil and @seg_vir_nil != nil
										if @prim_vir == @seg_vir
											@cartas.each do |carta2|
												if carta2.tipo == @prim_vir
													carta2.virada_sempre = true
												end
											end
										else
											@cartas.each do |carta2|
												if carta2.virada_sempre == false
													carta2.virada = false
												end
											end
										end
										@prim_vir = carta.tipo
										@seg_vir = nil
									end
									
									carta.virada = true
								end
							end
						end
				end
			end
			
			@clock.tick
			
			count = 0
			@cartas.each do |carta2|
				if carta2.virada_sempre == true or carta2.virada == true
					count += 1
				end
			end
			
			if count == 8
				@screen.title = "Memoria - Voce venceu!"
			end
		end
	end
	
	def desenhar
		@cartas.each do |carta|
			carta.desenhar(@background)
		end
	end
	
	def desenhar_carta(x, y)
		@background.draw_box(   [31+x,31+y], [69+x,69+y], [34,21,255] )
	end
	
	def setup_clock
		@clock = Clock.new()
		@clock.target_framerate = 50

    # Ajuste de granulidade adaptando ao sistema
    # Isto ajusta a minimizar o uso do processador
		@clock.calibrate

	end
end

screen = Screen.open([325,229])
screen.title = "Memoria"
queue = EventQueue.new()

jogo = Jogo.new(screen, queue)

jogo.rodar

Rubygame.quit
