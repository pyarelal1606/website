# encoding: utf-8

require "pg"

module Jekyll
	class Aktuelles < Jekyll::Generator
		def generate(site)
			return real(site) if ENV['DONT_HIDE_FAILURES']

			begin
				real(site)
			rescue => e
				warn "\n\nAktuelles ist kaputt. Fehlermeldung:"
				warn e.message
				warn e.backtrace.map{|x| "\t#{x}"}.join("\n")
				warn "\n\n"
			end
		end

		def real(site)
			conn = PGconn.open(:dbname => 'nnev')
			res = conn.exec('SELECT stammtisch, override, location, termine.date AS date, topic, abstract, vortraege.id AS c14h_id FROM termine LEFT JOIN vortraege ON termine.vortrag = vortraege.id WHERE termine.date >= CURRENT_DATE ORDER BY termine.date LIMIT 4')
			termine = []
			res.each do |tuple|
				tuple['stammtisch'] = (tuple['stammtisch'] == 't')
				termine << tuple
			end

			res = conn.exec('SELECT * FROM vortraege WHERE date IS NULL OR date >= CURRENT_DATE ORDER BY date ASC')
			vortraege_zukunft = []
			res.each do |tuple|
				vortraege_zukunft << tuple
			end

			res = conn.exec('SELECT * FROM vortraege WHERE date < CURRENT_DATE ORDER BY date DESC')
			vortraege_vergangenheit = []
			res.each do |tuple|
				vortraege_vergangenheit << tuple
			end

			site.pages.each do |page|
				page.data['termine'] = termine
				page.data['vortraege_zukunft'] = vortraege_zukunft
				page.data['vortraege_vergangenheit'] = vortraege_vergangenheit
			end
		end
	end
end
